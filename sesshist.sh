#!/bin/bash
# Arguments: List of IP addresses
#
sesshist() {
mypid=$$
rm -f consol$mypid.lis
ipargs=`echo $* | sed "s/[0-9.][0-9.]*/'&'/g
s/ /,/g"`
set -- `ls -t \`find . -name "capsess_vlan*.db*" -mtime -1 -print\` | head -2` 
if [ $# -gt 0 ]
then
    db1=$1
    export db1
    if [ $# -gt 1 ]
    then
    db2=$2
    else
    db2=
    export db2
    fi
{
    if [ ! -z "$db2" ]
    then
    echo "attach '$db2' as db1;"
    fi
    echo ".output consol$mypid.lis
    select a.dip,a.dport,min(a.sess_start),max(a.sess_start),count(*),sum(a.ct),sum(a.pout),sum(a.pin),sum(a.bout),sum(a.bin)
    from (
       select sess_start,dip,dport, (tsrc+tnsrc+tdst+tndst) as ct, pout,pin,bout,bin from capsess where sip = '10.200.$MENU_VLAN.75' and dip in ($ipargs)
       union
       select sess_start,sip,sport, (tsrc+tnsrc+tdst+tndst) as ct, pin,pout,bin,bout from capsess where dip = '10.200.$MENU_VLAN.75' and sip in ($ipargs)"
       if [ ! -z "$db2" ]
       then
       echo "union
       select sess_start,dip,dport, (tsrc+tnsrc+tdst+tndst) as ct, pout,pin,bout,bin from db1.capsess where sip = '10.200.$MENU_VLAN.75' and dip in ($ipargs)
       union
       select sess_start,sip,sport, (tsrc+tnsrc+tdst+tndst) as ct, pin,pout,bin,bout from db1.capsess where dip = '10.200.$MENU_VLAN.75' and sip in ($ipargs)"
       fi
       echo ") a
    group by a.dip,a.dport
    order by 1,2;"
} | sqlite3.8.6 $db1
fi
echo "IP|Port|First Seen|Last Seen|Times Seen|Connect Time|Packets Out|Packets In|Bytes Out|Bytes In"
if [ -f consol$mypid.lis ]
then
cat consol$mypid.lis
rm consol$mypid.lis
fi
return
}
