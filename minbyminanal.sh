#!/bin/bash
#
sqlite3 iis_logs.db << EOF | gawk -F"|" 'BEGIN {
    print "DateTime|Count|Total Time|Average Time|Std Dev|Clients|Upload|Download"
}
{print $1 "|" $2 "|" $3/1000 "|" $4/1000 "|" sqrt($5)/1000 "|" $6 "|" $7 "|" $8 }' >minbymin.txt
select substr(date_time,1,16),count(*),sum(time_taken),avg(time_taken),(sum(time_taken*time_taken)/count(*) - avg(time_taken)*avg(time_taken)),count(distinct c_ip),sum(cs_bytes),sum(sc_bytes) from iis_logs group by substr(date_time,1,16) order by 1;
EOF
