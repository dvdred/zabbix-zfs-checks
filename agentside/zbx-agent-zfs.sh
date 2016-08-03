#!/bin/bash
# Run as root user

# CUSTOM PARAMETERS:

[[ -d /etc/zabbix ]] || exit 1

[[ -d /etc/zabbix/zabbix_agentd.conf.d ]] && ln -s /etc/zabbix/zabbix_agentd.conf.d /etc/zabbix/zabbix_agentd.d

cat >"/etc/zabbix/zabbix_agentd.d/userparameter_zfs.conf"<<'EOF'
UserParameter=zpool.discover,/bin/discover-zfspool.sh
UserParameter=zpool.health[*],sudo zpool list -H -o health $1
UserParameter=zpool.stat[*],sudo zpool iostat $1 -y |tail -n 1
UserParameter=zpool.ioro.stat[*],sudo zpool iostat $1 5 1 -y |tail -n 1 | awk '{print $$4}'
UserParameter=zpool.iorw.stat[*],sudo zpool iostat $1 5 1 -y |tail -n 1 | awk '{print $$5}'

# CANNOT INCLUDE NEXT BECAUSE THERE IS NO SIMPLE WAY TO GET RAW DATA FROM zpool iostat COMMAND
#UserParameter=zpool.alloc.stat[*],sudo zpool iostat $1 -y |tail -n 1 | awk '{print $$2}'
#UserParameter=zpool.free.stat[*],sudo zpool iostat $1 -y |tail -n 1 | awk '{print $$3}'
#UserParameter=zpool.ro.stat[*],sudo zpool iostat $1 5 1 -y |tail -n 1 | awk '{print $$6}'
#UserParameter=zpool.rw.stat[*],sudo zpool iostat $1 5 1 -y |tail -n 1 | awk '{print $$7}'

# DATASETS
UserParameter=zsets.discover,/bin/discover-zfsdataset.sh
UserParameter=zsets.health[*],sudo zfs list -o mounted $1 |tail -n 1|tr -d ' '
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

cat >"/bin/discover-zfsdataset.sh"<<'EOF'
#!/bin/bash
################################################

declare -a datasets
#pools=(a b c)

n=0
#for i in $(/sbin/zpool list -H -o name) ; do
for i in $(sudo zfs list -H -o name | grep '/'); do
  datasets[$n]="$i"
  #echo "Pool: $n = $i"     #to confirm the entry
  let "n= $n + 1"
done

# Get length of an array
length=${#datasets[@]}
let "last= $length - 1"

for (( i=0; i<${length}; i++ ))
do
        if [ $i == $last ]; then
            DATASET="{\"{#ZFSDATASET}\":\"${datasets[$i]}\"}"
        else
            DATASET="{\"{#ZFSDATASET}\":\"${datasets[$i]}\"},"
        fi
    SETALL="$SETALL""$DATASET"
done

echo "{\"data\":["$SETALL"]}"
EOF
chmod a+x /bin/discover-zfsdataset.sh

cat >"/etc/sudoers.d/zabbixzfs"<<'EOF'
# Zabbix permission for polling zpool
    
Defaults:zabbix !requiretty   
zabbix ALL=NOPASSWD: /sbin/zpool
zabbix ALL=NOPASSWD: /sbin/zfs

EOF

echo "
##########################################

Remember to restart zabbix agent service!!

##########################################
"
