# zabbix-zfs-checks
This project includes a Zabbix Template (2.4) and all the resources (agent side) useful to monitor zpools used by zfs on linux

It use low level discovery rules to create items, triggers, graphs about your zfs pool on linux.

DONE
- bash script to install zabbix custom commands for agent
- zpool discovery
- zpool status
- zpool triggers if not ONLINE
- zpool stats (partial, restriction caused by the lack of raw data and not fixed Units added to the output of zpool iostat)

TODO
- zpool stats graph
- zpool stats trigger
- dataset discovery
- dataset status
- dataset triggers if not ONLINE
- dataset stats
