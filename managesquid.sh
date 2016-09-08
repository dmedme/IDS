#!/bin/bash
# Manage squid; maintain 10 GBytes of squid logs from the Ironport
. /home/dme/netcap/bin/fdbase.sh
# ***********************************************************************
# Function to track what is on the Ironport, and fetch, keeping up to 100
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
maintainsquid() {
#
# List squid stuff
#
squid_files=`ftp -in 10.200.$MENU_VLAN.75 << EOF | gawk '/aclog/ {print $NF}' | sort
user $MENU_IRONPORT_USER $MENU_IRONPORT_PASSWORD
cd accesslogs
ls aclog.*.s
quit
EOF
`
export squid_files
#
# If there are any, fetch new ones
#
if [ ! -z "$squid_files" ]
then
cd $MENU_HOME/squid
{
    echo "user $MENU_IRONPORT_USER $MENU_IRONPORT_PASSWORD
cd accesslogs"
    for fn in $squid_files
    do
        if [ ! -f "$fn" ]
        then
            echo get $fn
        fi 
    done
    echo quit
} | ftp -in 10.200.$MENU_VLAN.75
fi
#
# If there are now more than 60, trim them
#
    fcnt=`ls aclog*.s | wc -l`
    if [ "$fcnt" -gt 60 ]
    then
        trimcnt=`expr $fcnt - 60`
        rm -f `ls -tr aclog*.s | head -$trimcnt`
    fi
    return
}
cd $MENU_HOME/squid
#
# Main program starts here
#
while :
do
    maintainsquid
    sleep 600
done
