#!/bin/bash
#
sqlite3 capsessresp.db << EOF | gawk -F"|" 'BEGIN {
    print "DateTime|Count|TotalTime|AverageTime|StdDev|InPackets|OutPackets|InBytes|UpBytes"
}
{print $1 "|" $2 "|" $3 "|" $4 "|" sqrt($5) "|" $6 "|" $7 "|" $8 "|" $9 }' >10minby10min.txt
select substr(resp_start,1,16)||'0',count(*),sum(resp),avg(resp),(sum(resp*resp)/count(*) - avg(resp)*avg(resp)),sum(pin),sum(pout),sum(bin),sum(bout) from capresp where resp < 1000 group by substr(resp_start,1,16) order by 1;
EOF
