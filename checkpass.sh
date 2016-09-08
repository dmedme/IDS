#!/bin/bash
# *******************************************************
# Function to log on to a router and display the interface
export PATH=/home/e2soft/e2common:/home/e2soft/e2net:/home/e2soft/path:$PATH
export PATH
check_router() {
if [ $# -lt 4 ]
then
    echo Supply a router IP address username password and timestamp
    exit
fi
ROUTER=$1
USER=$2
PASSWORD=$3
TS=$4
export ROUTER USER PASSWORD TS
ptydrive -p -d -i 'A0:120:Username::User prompt ' -x "telnet $ROUTER" /dev/null 1 1 1 << EOF >/dev/null 2>check_$ROUTER.lis
\\W1\\
\\R5\\
'$USER'
\\SA1:20:assword::Password prompt\\
\\TA1:\\
'$PASSWORD'
\\SA2:20:#::Command prompt\\
\\TA2:\\
'enable'
\\TA2:\\
'show interfaces'
\\SA3:20:#:exit:--More--::Paged Display\\
\\TA3:\\
''
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
\\TA3:\\
' '
'exit'
EOF
}
ts=`tosecs`
while read rtr usr passwd
do
    check_router $rtr $usr $passwd $ts
done <fred.lis
