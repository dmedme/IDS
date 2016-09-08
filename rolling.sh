#!/bin/bash
. /home/dme/netcap/bin/fdbase.sh
MENU_LOCATION=${MENU_LOCATION:-Wherever}
MENU_LOC=${MENU_LOC:-Whe}
MENU_VLAN=${MENU_VLAN:-68}
MENU_HOST=${MENU_HOST:-netperf2}
MENU_IF=${MENU_IF:-eth2}
export MENU_LOCATION MENU_LOC MENU_HOST MENU_IF
cit_seq=0
db_seq=0
cd $MENU_HOME
>>${MENU_LOC}alerts.lis
# *****************************************************************************
# Function to process the alerts and e-Mail people
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
# This implementation will struggle if there are many alerts in a file ...
handle_alerts() {
afile=$1
ipfile=$2

    cat $afile>>${MENU_LOC}alerts.lis
    mv $ipfile $ipfile.sav
    echo "Subject: $MENU_LOCATION Alerts from $ipfile
From: netperf@$MENU_HOST" | cat - $afile | ssmtp $EMAIL_DIST

    iplist=`sed 's/[ |].*//' $afile | sort | uniq`
    iplabel=`echo $iplist | sed 's/[ 	]/_/g'`
    ipargs=`echo $iplist | sed 's/[0-9.][0-9.]*/ -i &/g'`
    if [ ! -s "$ipargs" ]
    then
        eval /usr/bin/nice -n -5 snoopfix -n -p -d -r -t $ipargs $ipfile.sav >>traff_$iplabel.log 
    fi
    rm $ipfile.sav
    return
}
# ******************************************************************************
# Function to preserve the session history in manageable chunks and sanity check
# VVVVVVVVVVVVVVVVVVVV
preserve_sess_hist() {
if [ -f capsess_vlan$MENU_VLAN.db ]
then
    if [ $db_seq -gt 5 ]
    then
        db_seq=0
    fi
    mv capsess_vlan$MENU_VLAN.db capsess_vlan$MENU_VLAN.db$db_seq
#
# SQL Access sample queries
#sqlite3 capsess_vlan68.db$db_seq << EOF &
#.output sqlaccess_vlan68_$db_seq.lis
#select distinct sip from capsess where ( dip = '10.200.68.202'
# or dip = '10.200.68.205' or dip = '10.200.35.70')
#   and (sip like '10.%' or sip like '192.168.%')
#union 
#select distinct dip from capsess where (sip = '10.200.68.202'
# or sip = '10.200.68.205' or sip = '10.200.35.70')
#   and (dip like '10.%' or dip like '192.168.%');
#select * from capsess where ( dip = '10.200.68.202'
# or dip = '10.200.68.205' or dip = '10.200.35.70')
#   and (sip like '10.%' or sip like '192.168.%')
#union 
#select * from capsess where (sip = '10.200.68.202'
# or sip = '10.200.68.205' or sip = '10.200.35.70')
#   and (dip like '10.%' or dip like '192.168.%');
#.output posstunnel_vlan68_$db_seq.lis
#select * from capsess where
# dip in ( '10.200.34.75','10.200.68.75')
#   and sip not like '10.%'
#   and sip not like '192.168.%'
#   and sport in (80,443)
#   and pin > 10
#   and pout > 10
#   and bout < bin
#union 
#select * from capsess where
# sip in ( '10.200.34.75','10.200.68.75')
#   and dip not like '10.%'
#   and dip not like '192.168.%'
#   and dport in (80,443)
#   and pin > 10
#   and pout > 10
#   and bout > bin;
#select distinct sip from capsess where
# dip in ( '10.200.34.75','10.200.68.75')
#   and sip not like '10.%'
#   and sip not like '192.168.%'
#   and sport in (80,443)
#   and pin > 10
#   and pout > 10
#   and bout < bin
#union 
#select distinct dip from capsess where
# sip in ( '10.200.34.75','10.200.68.75')
#   and dip not like '10.%'
#   and dip not like '192.168.%'
#   and dport in (80,443)
#   and pin > 10
#   and pout > 10
#   and bout > bin;
#.output nochance_vlan68_$db_seq.lis
#select * from capsess where
# dip not in ( '10.200.34.75','10.200.68.75')
#   and sip not like '10.%'
#   and sip not like '192.168.%'
#   and sport in (80,443)
# union 
#select * from capsess where
# sip not in ( '10.200.34.75','10.200.68.75')
#   and dip not like '10.%'
#   and dip not like '192.168.%'
#   and dport in (80,443);
#select distinct sip from capsess where
# dip not in ( '10.200.34.75','10.200.68.75')
#   and sip not like '10.%'
#   and sip not like '192.168.%'
#   and sport in (80,443)
# union 
#select distinct dip from capsess where
# sip not in ( '10.200.34.75','10.200.68.75')
#   and dip not like '10.%'
#   and dip not like '192.168.%'
#   and dport in (80,443);
#EOF
    db_seq=`expr $db_seq + 1`
fi
sqlite3 capsess_vlan${MENU_VLAN}.db << EOF
create table capsess (
sess_start datetime not null,
sip varchar(16) not null,
sport integer null,
dip varchar(16) not null,
dport integer null,
tsrc double,
tnsrc double,
tdst double,
tndst double,
pout int64,
pin int64,
bout int64,
bin int64,
indic char(2));
EOF
    export db_seq
}
if [ $# -lt 1 ]
then
#    tcpdump -W 20 -C 1000 -s 0 -i eth0 -w vlan${MENU_VLAN}.trc \( port 1494 or port 2598 or port 80 or port 8080 or port 443 \) and \( host 10.200.68.210 or host 10.200.35.6 or host 10.200.35.7 or host 10.200.35.8 or host 10.200.35.9 or host 10.200.35.10 or host 10.200.35.11 \) &
    preserve_sess_hist
    ifconfig eth0 up
    tcpdump -W 40 -C 1000 -s 0 -i $MENU_IF -w vlan$MENU_VLAN.trc  &
    tcpd_pid=$!
    seq=0
else
    seq=$1
    tcpd_pid=
fi
while :
do
    case $seq in
?)
        fname=vlan$MENU_VLAN.trc0$seq
        ;;
*)
        fname=vlan$MENU_VLAN.trc$seq
        ;;
    esac
# Wait until the file has been closed
    while :
    do
        currf=`ls -1t vlan$MENU_VLAN.trc* | head -1`
        if [ "$currf" != "$fname" -a -n "$currf" -a -n "$fname" ]
        then
            break
        fi
        sleep 20
    done
    /usr/bin/nice -n -5 genconv -w alert.lis:whois.bin:country.bin:sql.bin -t $fname 2>&1 | grep '|Session ' | tee sessum.lis |
gawk -F"|" '/\|Session / {
# 7 Mar 2012 13:35:24.573569|Session Complete|02:01:0a:7d:14:bb|00:19:b9:f6:b7:74|TCP|10.125.20.178|10.125.20.188|1602|2312|16|24|5242|6416|0|0|0.000176|0.002263|0.006866|0.000105|
    if (substr($6,1,10) == "10.110.65.")
        print $1 "|" $2 "|" $4 "|" $3 "|" $5 "|" $7 "|" $6 "|" $9 "|" $8 "|" $11 "|" $10 "|" $13 "|" $12 "|" $15 "|" $14 "|" $19 "|" $18 "|" $17 "|" $16 "|"
    else
        print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17 "|" $18 "|" $19 "|"
}' | sort -t"|" -k 6,6 -k 8,8 -k 7,7 -k 9,9 -k 1,1 | gawk -F "|" '{
# Accumulate sessions that straddle multiple time periods
    lk = ""
}
function output_line() {
    print lt "|" lind "|" lse "|" lde "|TCP|" lsip "|" ldip "|" lsport "|" ldport "|" lscnt "|" ldnt "|" lsvol "|" ldvol "|" lsret "|" ldret "|" lctim "|" lcntim "|" lsntim "|" lstim "|"
    return
}
{
    tk = $6 "|" $8 "|" $7 "|" $9
    if (tk != lk )
    {
        if (lk != "")
        {
            if (lind == "Session Summary")
                lind = "Session Complete"
            output_line()
        }
        lt  = $1
        lind  = $2
        lse  = $3
        lde  = $4
        lsip  = $6
        ldip  = $7
        lsport  = $8
        ldport  = $9
        lscnt  = $10
        ldnt  = $11
        lsvol  = $12
        ldvol  = $13
        lsret  = $14
        ldret  = $15
        lctim  = $16
        lcntim  = $17
        lsntim  = $18
        lstim  = $19
    }
    else
    {
# Lose time here, hopefully not much. 
        lscnt += $10
        ldnt += $11
        lsvol += $12
        ldvol += $13
        lsret += $14
        ldret += $15
        lctim += $16
        lcntim += $17
        lsntim += $18
        lstim += $19
    }
    if ($2 == "Session Complete" || $2 == "Session Reset")
    {
        lind = $2
        output_line()
        lk = ""
    } 
}' |
gawk -F"|" 'BEGIN {
# Load the database
print "begin transaction;"
}
{
    print "insert into capsess ( sess_start, sip, sport, dip, dport, tsrc, tnsrc, tdst, tndst, pout, pin, bout, bin, indic) values ("
    if ($2 == "Session Complete")
        ind = 0
    else
    if ($2 == "Session Summary")
        ind = 1
    else
        ind = 2
    printf "'\''%s'\'','\''%s'\'',%d,'\''%s'\'',%d, %f, %f, %f, %f, %d, %d, %u, %u, %u);\n", $1, $6, $8, $7, $9, $16, $17, $18, $19, $10, $11, $12, $13, ind
}
END { print "commit;" }' | sqlite3 capsess_vlan$MENU_VLAN.db

    alert_size=`stat -c %s alert.lis`
    if [ "$alert_size" -gt 0 ]
    then
        handle_alerts alert.lis $fname
    fi
    db_size=`stat -c %s capsess_vlan$MENU_VLAN.db`
    if [ "$db_size" -gt 2000000000 ]
    then
        preserve_sess_hist
    fi
    seq=`expr $seq + 1`
    if [ $seq -gt 39 ]
    then
        seq=0
    fi
done
