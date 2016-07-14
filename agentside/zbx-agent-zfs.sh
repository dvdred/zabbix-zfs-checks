#!/bin/bash
# Run as root user

# CUSTOM PARAMETERS:

[[ -d /etc/zabbix ]] || exit 1

[[ -d /etc/zabbix/zabbix_agentd.conf.d ]] && ln -s /etc/zabbix/zabbix_agentd.conf.d /etc/zabbix/zabbix_agentd.d

cat >"/etc/zabbix/zabbix_agentd.d/userparameter_zfs.conf"<<'EOF'
UserParameter=zpool.discover,/bin/discover-zfspool.sh
UserParameter=zpool.health[*],sudo zpool list -H -o health $1
EOF

cat >"/bin/discover-zfspool.sh"<<'EOF'
#!/bin/bash
declare -a pools
#pools=(a b c)

n=0
#for i in $(/sbin/zpool list -H -o name) ; do
for i in $(sudo zpool list -H -o name); do
  pools[$n]="$i"
  #echo "Pool: $n = $i"     #to confirm the entry
  let "n= $n + 1"
done
# Get length of an array
length=${#pools[@]}
let "last= $length - 1"

for (( i=0; i<${length}; i++ ))
do
        if [ $i == $last ]; then
            POOL="{\"{#ZFSPOOL}\":\"${pools[$i]}\"}"
        else
            POOL="{\"{#ZFSPOOL}\":\"${pools[$i]}\"},"
        fi
    POOLALL="$POOLALL""$POOL"
done

echo "{\"data\":["$POOLALL"]}"
EOF

chmod a+x /bin/discover-zfspool.sh

cat >"/etc/sudoers.d/zabbixzfs"<<'EOF'
# Zabbix permission for polling zpool
    
Defaults:zabbix !requiretty   
zabbix ALL=NOPASSWD: /sbin/zpool
EOF

echo "
##########################################

Remember to restart zabbix agent service!!

##########################################
"
