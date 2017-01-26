# zabbix-zfs-checks
This project includes a Zabbix Template (2.4) and all the resources (agent side) useful to monitor zpools used by zfs on linux

It uses low level discovery rules to create items, triggers and graphs about your zfs pools on linux host (mostly debian and centos supported).

Read MACRO.md to set the Regular Expression Filters needed by this template to not collide with other templates (TODO check if it is really useful).

AGENTSIDE: run bash script to install or update zabbix custom commands for the agent:
- zpool discovery
- zpool status
- zpool stats
- zpool stats graph
- zpool triggers if not ONLINE
- zpool trigger for low space
- dataset discovery
- dataset status
- dataset stats (space only)
- dataset triggers if not MOUNTED
- dataset trigger for low space
