#!/bin/bash
#. /home/dme/netcap/bin/fdbase.sh
# *******************************************************
# Function to execute a grep against an Ironport
ironport_grep() {
if [ $# -lt 4 ]
then
    echo Supply an ironport IP address username password and regular expression
    exit
fi
IRONPORT=$1
USER=$2
PASSWORD=$3
REX=$4
export IRONPORT USER PASSWORD REX
ptydrive -p -d -i 'A0:120:assword::yes/no:yes:Password prompt ' -x "ssh $USER@$IRONPORT" /dev/null 1 1 1 << EOF >/dev/null 2>ironport_grep.lis &
\\W1\\
\\R5\\
'$PASSWORD'
\\SA2:120:.com>::Command prompt\\
\\TA2:\\
'grep'
\\SA3:120:]>::Sub prompt\\
\\TA3:\\
'1'
\\TA3:\\
'$REX'
\\TA3:\\
'Y'
\\TA3:\\
'N'
\\TA3:\\
'N'
\\TA3:\\
'N'
\\TA2:\\
'exit'
\\SA4:120:closed::Exit confirmed\\
\\TA4:\\
''
EOF
#
# If there is a control terminal, ptydrive will detach, so we have to run it in
# the background and wait for it to finish in a rather cack-handed way. If we don't
# background it, and it doesn't detach itself, and it hangs, we are stuck.
cnt=1
while ps -ef | grep 'ptydri[v]e.*yes' >/dev/null
do
    if [ $cnt -gt 20 ]
    then
        ps -ef | gawk '/ptydri[v]e.*yes/ { print $2}' | while read pid
        do
            kill $pid
        done
        break
    fi
    sleep 5
    cnt=`expr $cnt + 1`
done
if grep "No results were found. Use another regular expression" ironport_grep.lis >/dev/null
then
    return 1
else
    sed -n '/^[12][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.[0-9]/ {
s///
p
}' ironport_grep.lis
    return 0
fi
}
# *****************************
# Fail test
#if ironport_grep 10.200.$MENU_VLAN.75 e2 'Zp-6p0$3!5_B' iploc.co.uk
#then
#    echo Funny - expected to fail
#else
#    echo Good - failed
#fi
#if ironport_grep 10.200.$MENU_VLAN.75 e2 'Zp-6p0$3!5_B' http://www.yalwa.co.uk
#then
#    echo Good - succeeded
#else
#    echo Funny - expected to succeed
#fi
#exit
