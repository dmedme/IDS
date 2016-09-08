#!/bin/bash
sqlite3 capsess.db << EOF
.output interesting.lis
select hosts.name,capsess.* from capsess, hosts where
 dip = '10.200.34.152'
   and sip like '10.%'
 and hosts.ip = capsess.sip
 union 
select hosts.name,capsess.* from capsess,hosts where
 sip = '10.200.34.152'
   and dip like '10.%'
 and hosts.ip = capsess.dip
 and sess_start between '13 Jun 2014 12:00:00' 
 and  '13 Jun 2014 15:05:00';
EOF
