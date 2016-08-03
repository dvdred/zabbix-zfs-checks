# Macro and filters to add to zabbix configuration

## Discovery rule used by this template needs Regular Expression Filters: 
For Pool discovery
```
Label	Macro	 	Regular expression
A	{#ZFSPOOL}	@Linux ZFS Zpool
```

For Dataset discovery
```
Label   Macro           Regular expression
A	{#ZFSDATASET}	@Linux ZFS Zsets
```

## ADD THIS TWO REGULAR EXPRESSION TO:
Administration -> General -> Regular Expression
```
- NAME:	Linux ZFS Zpool	
1	» 	^\b[a-zA-Z0-9_]+\b$	[Result is TRUE]
2	» 	^(hd[a-z]+|sd[a-z]+|vd[a-z]+|docker[0-9]+|dm-[0-9]+|drbd[0-9]+)$	[Result is FALSE]
3	» 	^(vzsnap.*|.*-cow|.*-real|ram[0-9]+|loop[0-9]+|sr[0-9]*|fd[0-9]*)$	[Result is FALSE]

- NAME:	Linux ZFS Zsets	
1	» 	/	[Character string included]
2	» 	^(hd[a-z]+|sd[a-z]+|vd[a-z]+|docker[0-9]+|dm-[0-9]+|drbd[0-9]+)$	[Result is FALSE]
3	» 	^(vzsnap.*|.*-cow|.*-real|ram[0-9]+|loop[0-9]+|sr[0-9]*|fd[0-9]*)$	[Result is FALSE]
```
