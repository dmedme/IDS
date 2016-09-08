#!/bin/bash
sqlite3 whois.db << EOF
.output country.lis
select lowipno,hiipno,iprange,rating,country from geo_blocks order by 1,2;
.output whois.lis
select distinct lowipno,hiipno,iprange,blocks.rating,blocks.name||','||b.address||','||b.country||','||b.email from blocks,parties b where iprange != '-' and b.hndle = blocks.owner_hndle order by 1,2;
EOF
/home/e2soft/e2common/ascbin -a -s"|" 2I4 3S <whois.lis >whois.bin
/home/e2soft/e2common/ascbin -a -s"|" 2I4 3S <country.lis >country.bin
