#!/bin/bash
sqlite3 capsess.db << EOF
.output good.lis
select distinct hosts.name from capsess, hosts where ( dip = '10.200.68.202'
 or dip = '10.200.68.205' or dip = '10.200.35.70')
 and hosts.ip = capsess.sip
 union 
select distinct hosts.name from capsess,hosts where (sip = '10.200.68.202'
 or sip = '10.200.68.205' or sip = '10.200.35.70')
 and hosts.ip = capsess.dip;
EOF
