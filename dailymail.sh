#!/bin/bash
# Send a daily mail report.
#
# Environment set-up. Running from cron, this starts empty
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH
MENU_HOME=/home/dme/netcap
export MENU_HOME
cd $MENU_HOME
. $MENU_HOME/bin/fdbase.sh
. $MENU_HOME/bin/sesshist.sh
#. $MENU_HOME/bin/callironport.sh
#. $MENU_HOME/bin/ironportusers.sh
. $MENU_HOME/bin/localusers.sh
. $MENU_HOME/bin/digest.sh
. $MENU_HOME/bin/getcert.sh
MENU_LOCATION=${MENU_LOCATION:-Manchester}
MENU_LOC=${MENU_LOC:-man}
MENU_HOST=${MENU_HOST:-netperf2}
export MENU_LOCATION MENU_LOC MENU_HOST
#
# House Keeping - correct date and kill off old sessions
ntpdate 10.200.34.41
if [ -z "$MENU_INTER" ]
then
killall ptydrive
fi
cd /home/dme/netcap
rm -f alltraff.z*
#
# Identify the report period
#
now=`date +%s`
export now
prev=`sqlite3 mailhist.db << EOF
select max(timestamp) from mailhist;
EOF
`
if [ -z "$prev" ]
then
# 18 Sep 2014 06:00:00 to bootstrap
    prev=1411020000
fi
mins=`expr \( $now - $prev \) / 60`
# 
# Remove older traff*.log files
find . -name "traff*.log" -mmin +$mins -exec rm \{\} \;
trap "" 0 1
#
# The actual Mail
{
mv ${MENU_LOC}alerts.lis ${MENU_LOC}alerts.mailed
    echo "Subject: $MENU_LOCATION netperf Daily Summary Report
From: netperf@$MENU_HOST
MIME-Version: 1.0
Content-Type: "'Multipart/Related;
      boundary="_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_";
      Type="text/plain"

--_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7-bit

Running Status
--------------
Disk space
----------'
df -k .
echo "Monitoring Processes (need rolling.sh, managesquid.sh and tcpdump)
------------------------------------------------------"
ps -efww | egrep 'ro[l]ling|tcp[d]ump|manages[q]uid'
echo "=====================================================
Interesting IP's
---------------------"
echo "Digest"
echo "-------------"
allips=`sed 's/[ |].*$//' ${MENU_LOC}alerts.mailed | sort | uniq`
#
# Find out all we can from the captured data, whois and the SSL certificates
#
ipdigest $allips
#
# Look for users via the Ironport
#ironportusers $now
localusers $now
#
# Consolidate Session Data
sesshist $allips | gawk -F"|" 'BEGIN {
print "begin transaction;"|"sqlite3 mailhist.db"
getline
}
{ 
print "insert into consolhist ( timestamp, ip, dport, min_sess_start, max_sess_start, seen, ct, pout, pin, bout, bin) values ('$now','\''" $1 "'\''," $2 ",'\''" $3 "'\'','\''" $4 "'\''," $5 ","  $6 ","  $7 ","  $8 ","  $9 ","  $10 ");"|"sqlite3 mailhist.db"
}
END {
print "commit;"|"sqlite3 mailhist.db"
}'
#
# Finally, report everything in a line
echo "IP|Port|Reverse DNS|Host|Refer|Users|Repute|Whois|First Seen|Last Seen|Times Seen|Connect Time|Packets Out|Packets In|Bytes Out|Bytes In"
echo "---------------------------------------------------------------------------------------------------------------------------------------------"
sqlite3.8.6 mailhist.db << EOF
select distinct a.ip, b.dport, a.revdns, a.host, a.refer, a.users,a.category, a.whois, b.min_sess_start, b.max_sess_start, b.seen, b.ct, b.pout, b.pin, b.bout, b.bin
 from mailhist a left outer join consolhist b
   on a.ip = b.ip
   and a.timestamp = b.timestamp
where
    a.timestamp = $now
order by 1,2;
EOF
echo "====================================="
echo "Consolidated Alert e-Mails
---------------------------"
cat ${MENU_LOC}alerts.mailed
echo "=====================================
Supporting Data
---------------"
find . -name "traff_*.log" -mmin -$mins -ls
echo "====================================="
for i in `find . -name "traff_*.log" -mmin -$mins -print`
do
echo "====================================="
ls -l $i
echo "-------------------------------------"
cat $i
done >alltraff.lis
echo "=====================================" >>alltraff.lis
rm -f alltraff.z*
zip -s 25m alltraff.zip alltraff.lis
sz=`stat -c %s alltraff.zip`
dt=`stat -c %y alltraff.zip`
echo "
--_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_
Content-Type: application/octet-stream;
	name="'"'alltraff.zip'"'"
Content-Description: alltraff.zip
Content-Disposition: attachment;
	filename="'"'alltraff.zip'";' size=$sz";
	creation-date="'"'$dt'"'";
	modification-date="'"'$dt'"'"
Content-Transfer-Encoding: base64
"
base64 alltraff.zip
echo "
--_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_--"
} >dailymail.txt
#
# Have to decouple to avoid timeouts
#
ssmtp $EMAIL_DIST <dailymail.txt
for extfile in alltraff.z0?
do
if [ -f $extfile ]
then
{
    echo "Subject: $MENU_LOCATION netperf Daily Summary Report (continued)
From: netperf@$MENU_HOST
MIME-Version: 1.0
Content-Type: "'Multipart/Related;
      boundary="_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_";
      Type="text/plain"

--_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7-bit

'
echo Further component of alltraff.zip - $extfile

sz=`stat -c %s $extfile`
dt=`stat -c %y $extfile`
echo "
--_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_
Content-Type: application/octet-stream;
	name="'"'$extfile'"'"
Content-Description: $extfile
Content-Disposition: attachment;
	filename="'"'$extfile'";' size=$sz";
	creation-date="'"'$dt'"'";
	modification-date="'"'$dt'"'"
Content-Transfer-Encoding: base64
"
base64 $extfile
echo "
--_002_222903A587680E45A1CE5FB5CB53CB7514D77A5BFPAK1EXN01_--"
} | ssmtp $EMAIL_DIST
fi
done
