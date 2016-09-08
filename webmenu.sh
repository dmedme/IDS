#!/bin/bash
# webmenu.sh - Menu of options for Managing Intrusion Detection
# @(#) $Name$ $Id$
# Copyright (c) E2 Systems Limited 1993, 2014
#
# This version is for invocation from the secure multi-threaded server.
# ***************************************************************************
# Parameters : None
set -x
MENU_INTER=1
export MENU_INTER
# *************************************************************************
# Function to update the permitted database manually
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
manwhois() {
while :
do
narrative=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=MANWHOIS: Add host ranges to the white list
PROMPT=Fill in the details and Press RETURN
COMMAND=MANWHOIS:
SEL_NO/COMM_NO/SYSTEM
SCROLL
First IP  :
Second IP :
Country   :
Narrative :

EOF
`
message_text=
export message_text
eval set -- $narrative
case "$1" in
*MANWHOIS:*)
shift
if [ $# -gt 0 ]
then
    cntry=
    remarks=
    ip1=$1
    shift
    if [ $# -gt 0 ]
    then
        ip2=$1
        shift
        if [ $# -gt 0 ]
        then
            cntry=$1
            shift
            if [ $# -gt 0 ]
            then
                remarks=$1
            fi
        fi
    fi
    if [ -z "$ip2" ]
    then
        ip2=$ip1
    fi
    if echo $ip1 | grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
    then
        if echo $ip2 | grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
        then
            gawk 'BEGIN {
    ini_whois()
    ip1=trim("'$ip1'")
    ip2=trim("'$ip2'")
    cntry=trim("'$cntry'")
    remarks=trim("'$remarks'")
    lowipno=getipno(ip1)
    hiipno=getipno(ip2)
    if (lowipno > hiipno)
    {
        i = lowipno
        lowipno = hiipno
        hiipno = i
        ip = ip1
        ip1 = ip2
        ip2 = ip
    }
    iprange=ip1 "-" ip2
    owner_hndle = iprange
    do_block(ip1,ip2, remarks, owner_hndle)
    do_parties(owner_hndle,"OWN",owner_hndle,remarks,"",cntry,"")
}
function getipno(ip) {
    split(ip,arr,".")
    return arr[1]*256*256*256 + arr[2]*256*256 + arr[3]*256 + arr[4]
}
function ini_whois() {
iprange = ""
lowip = ""
hiip = ""
lowipno = 0
hiipno = 0
name = ""
owner_hndle = ""
abuse_hndle = ""
admin_hndle = ""
tech_hndle = ""
name = ""
address = ""
country = ""
email = ""
blnk_flag = 0
return
}
function trim(x) {
sub(/^[ 	][ 	]*/,"",x)
sub(/[ 	][ 	]*$/,"",x)
gsub("'\''","'\'\''",x)
    return x
}
function do_block(lowip,hiip, name, owner_hndle) {
print "insert into blocks ( iprange, lowipno, hiipno, name, owner_hndle) values ("
iprange = lowip "-" hiip
lowipno = getipno(lowip)
hiipno = getipno(hiip)
printf "'\''%s'\'',%u,%u,'\''%s'\'','\''%s'\'');\n",iprange,lowipno,hiipno,name,owner_hndle
    return
}
function do_parties(owner_hndle,role,hndle,name,address,country,email) {
print "insert into parties ( hndle, name, address, country, email) values ("
printf "'\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'');\n",hndle,name,address,country,email
print "insert into party_roles(party1_hndle, party2_hndle, role_abbr, email) values ("
printf "'\''%s'\'','\''%s'\'','\''%s'\'','\''%s'\'');\n",owner_hndle,hndle,role,email
return
}' /dev/null | sqlite3 whois.db
            propagate
        else
            message_text="IP Address Format Invalid"
            export message_text
        fi
    fi
fi
;;
*)
return
;;
esac
done
}
# *************************************************************************
# Function to collect as much as possible about an IP
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
# *************************************************************************
allaboutip() {
ip=$1
export ip
now=0
export now
sqlite3 mailhist.db "delete from mailhist where timestamp = 0 and ip='$ip';"
ipdigest $ip
#ironportusers 0
localusers 0
sqlite3 mailhist.db "select a.ip, a.revdns, a.host, a.refer, a.users,a.category from mailhist a where a.timestamp=0 and a.ip='$ip';" | sed 's/</\&lt;/g
s/>/\&gt;/g' | (html_head=""
html_tail=""
export html_head html_tail
wbrowse -r -t"|" -l "Summary for IP $ip" -c "IP|Reverse DNS|Host|Refer|Users|Categorisation" -
)
sqlite3 mailhist.db "delete from mailhist where timestamp = 0 and ip='$ip';"
    return
}
# Function to update using whois data
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
autowhois() {
while :
do
narrative=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=AUTOWHOIS: Add host ranges to the white list automatically
PROMPT=Fill in the details and Press RETURN
COMMAND=AUTOWHOIS:
SEL_NO/COMM_NO/SYSTEM
SCROLL
List of IP addresses  :

EOF
`
message_text=
export message_text
eval set -- $narrative
case "$1" in
*AUTOWHOIS:*)
shift
if [ $# -gt 0 ]
then
    new_whois $*
    load_whois new_whois.lis
    propagate
fi
;;
*)
return
;;
esac
done
    return
}
# *************************************************************************
# Function to execute shell command and display output
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
arbitrary() {
while :
do
cmdline=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=ARBITRARY: Execute arbitrary shell commands as super-user
PROMPT=Enter the command line and submit
COMMAND=ARBITRARY:
SEL_NO/COMM_NO/SYSTEM
SCROLL
Arbitrary Command  :

EOF
`
message_text=
export message_text
eval set -- $cmdline
case "$1" in
*ARBITRARY:*)
shift
if [ $# -gt 0 ]
then
    {
        eval `echo $* | sed 's/+/ /g'`
    } 2>&1 | output_dispose "ARBITRARY: Command output ..."
fi
;;
*)
return
;;
esac
done
    return
}
# *************************************************************************
# Function to execute a query
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
do_query() {
db_name=$1
qry_txt=$2
label=$3
cols=$4
        sqlite3.8.6 $db_name<< EOF | wbrowse -r -t"|" -c "$cols" -l "$label" - | e2fifout ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID
$qry_txt
EOF
        e2fifin 1>&2 ${NAMED_PIPE_PREFIX}script_in_fifo.$E2_WEB_PID
    return
}
# *************************************************************************
# Function to search for sessions
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
sessions() {
while :
do
ips=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=SESSIONS: Find recent sessions for an IP Address
PROMPT=Enter the IP address and submit
COMMAND=SESSIONS:
SEL_NO/COMM_NO/SYSTEM
SCROLL
IPv4 Address (x.x.x.x)  :

EOF
`
message_text=
export message_text
eval set -- $ips
case "$1" in
*SESSIONS:*)
shift
if [ $# -gt 0 ]
then
    ip=$1
    if echo $ip | grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
    then
        heading=`allaboutip $ip`
        (
            html_head="$html_head $heading"
            export html_head
        do_query capsess_vlan$MENU_VLAN.db "select sess_start,(tsrc+tnsrc+tdst+tndst),sip,sport,dip,dport,pout,pin,bout,bin from capsess where '$ip' in (sip,dip) order by rowid;" "Recent Sessions for $ip"  "Start Time|Duration|From IP|From Port|To IP|To Port|Packets Out|Packets In|Bytes Out|Bytes In"
        )
    else
        message_text="IP Address $ip not a valid IPv4 Numeric Address"
        export message_text
    fi
fi
;;
*)
return
;;
esac
done
    return
}
# *************************************************************************
# Function to search for the country for an IP Address
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
country() {
while :
do
ips=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=COUNTRY: Find country for an IP Address
PROMPT=Enter the IP address and submit
COMMAND=SESSIONS:
SEL_NO/COMM_NO/SYSTEM
SCROLL
IPv4 Address (x.x.x.x)  :

EOF
`
message_text=
export message_text
eval set -- $ips
case "$1" in
*COUNTRY:*)
shift
if [ $# -gt 0 ]
then
    ip=$1
    if echo $ip | grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
    then
        set -- `echo $ip | sed 's/\./ /g'`
        do_query whois.db "select iprange,country from geo_blocks where $1*256*256*256+$2*256*256+$3*256+$4 between lowipno and hiipno order by 1;" "Range and Country $ip"  "IP Range|Country"
    else
        message_text="IP Address $ip not a valid IPv4 Numeric Address"
        export message_text
    fi
fi
;;
*)
return
;;
esac
done
    return
}
# *************************************************************************
# Function to search for sessions
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
querywhois() {
while :
do
ips=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=QUERYWHOIS: Find whois data for an IP Address
PROMPT=Enter the IP address and submit
COMMAND=QUERYWHOIS:
SEL_NO/COMM_NO/SYSTEM
SCROLL
IPv4 Address (x.x.x.x)  :

EOF
`
message_text=
export message_text
eval set -- $ips
case "$1" in
*WHOIS:*)
shift
if [ $# -gt 0 ]
then
    ip=$1
    if echo $ip | grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
    then
        set -- `echo $ip | sed 's/\./ /g'`
        do_query whois.db "select iprange,name||' '||owner_hndle from blocks where $1*256*256*256+$2*256*256+$3*256+$4 between lowipno and hiipno order by 1;" "Range and ISP data for $ip"  "IP Range|ISP Data"
    else
        message_text="IP Address $ip not a valid IPv4 Numeric Address"
        export message_text
    fi
fi
;;
*)
return
;;
esac
done
    return
}
# *************************************************************************
# Function to search for the country for an IP Address
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
country() {
while :
do
ips=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=COUNTRY: Find country for an IP Address
PROMPT=Enter the IP address and submit
COMMAND=SESSIONS:
SEL_NO/COMM_NO/SYSTEM
SCROLL
IPv4 Address (x.x.x.x)  :

EOF
`
message_text=
export message_text
eval set -- $ips
case "$1" in
*COUNTRY:*)
shift
if [ $# -gt 0 ]
then
    ip=$1
    if echo $ip | grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null
    then
        set -- `echo $ip | sed 's/\./ /g'`
        do_query whois.db "select iprange,country from geo_blocks where $1*256*256*256+$2*256*256+$3*256+$4 between lowipno and hiipno order by 1;" "Range and Country $ip"  "IP Range|Country"
    else
        message_text="IP Address $ip not a valid IPv4 Numeric Address"
        export message_text
    fi
fi
;;
*)
return
;;
esac
done
    return
}
# *************************************************************************
# Function to search for sessions
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
consol() {
while :
do
ips=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=CONSOL: List Consolidated Session Data for Multiple IP Addresses
PROMPT=Enter IP addresses and submit
COMMAND=CONSOL:
SEL_NO/COMM_NO/SYSTEM
SCROLL
IPv4 Addresses (x.x.x.x)  :
IPv4 Addresses (x.x.x.x)  :
IPv4 Addresses (x.x.x.x)  :
IPv4 Addresses (x.x.x.x)  :

EOF
`
message_text=
export message_text
eval set -- $ips
case "$1" in
*CONSOL:*)
shift
if [ $# -gt 0 ]
then
    sesshist `echo $* | sed 's/+/ /g'` | wbrowse -r -t"|" -l "Consolidated Session History" - | e2fifout ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID
        e2fifin 1>&2 ${NAMED_PIPE_PREFIX}script_in_fifo.$E2_WEB_PID
fi
;;
*)
return
;;
esac
done
    return
}
# ************************************************
# Function to propagate updates to both targets
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
propagate() {
    prepare_bins
    if ifconfig | grep 10.200.68.142 >/dev/null
    then
        :
    else
        minitest 10.200.68.142 5000 COPY whois.db whois.db </dev/null 2>&1
        minitest 10.200.68.142 5000 COPY sql.bin sql.bin </dev/null 2>&1
        minitest 10.200.68.142 5000 COPY whois.bin whois.bin </dev/null 2>&1
        minitest 10.200.68.142 5000 COPY country.bin country.bin </dev/null 2>&1
    fi
    if ifconfig | grep 10.200.34.142 >/dev/null
    then
        :
    else
        minitest 10.200.34.142 5000 COPY whois.db whois.db </dev/null 2>&1
        minitest 10.200.34.142 5000 COPY sql.bin sql.bin </dev/null 2>&1
        minitest 10.200.34.142 5000 COPY whois.bin whois.bin </dev/null 2>&1
        minitest 10.200.34.142 5000 COPY country.bin country.bin </dev/null 2>&1
    fi
    message_text="Update propagated"
    export message_text
    return
}
# ************************************************
# Initialisation
# VVVVVVVVVVVVVV
MENU_SOURCE=${MENU_SOURCE:-/c/e2/web_path_web}
export MENU_SOURCE
if [ ! -f $MENU_SOURCE/fdvars.sh ]
then
    echo "No script files in designated SOURCE directory"
    exit 1
fi
. $MENU_SOURCE/fdvars.sh
. $MENU_SOURCE/loadwhois.sh
. $MENU_SOURCE/sesshist.sh
. $MENU_SOURCE/digest.sh
. $MENU_SOURCE/getcert.sh
#. $MENU_SOURCE/callironport.sh
#. $MENU_SOURCE/ironportusers.sh
. $MENU_SOURCE/localusers.sh
cd $MENU_HOME
if [ ! "$PATH_WKB" = tty ]
then
# ****************************************************************************
# Main Program Starts Here
# VVVVVVVVVVVVVVVVVVVVVVVV
# *************************************************************************
#
set -x
#
# The output from each dynamic request is passed as an input line to
# script_in_fifo. There should be one incarnation of this per form.
#
if [ ! "$MENU_OS" = NT4 ]
then
    mkfifo $MENU_HOME/sessions/script_out_fifo.$E2_WEB_PID
    until [ -p $MENU_HOME/sessions/web_fifo.$E2_WEB_PID -a -p $MENU_HOME/sessions/script_in_fifo.$E2_WEB_PID ]
    do
        sleep 1
    done
fi
#
# Discard the first response from the webserver
#
e2fifin ${NAMED_PIPE_PREFIX}script_in_fifo.$E2_WEB_PID
#
# Re-direct output from the shell scripts to a file, and pass the name of
# that file to the web server.
#
while :
do
    e2fifin ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID >$MENU_HOME/sessions/tmp$E2_WEB_PID.html
    echo $MENU_HOME/sessions/tmp$E2_WEB_PID.html
#
# Wait for the previous incarnation to be displayed
#
    while [ -f $MENU_HOME/sessions/tmp$E2_WEB_PID.html ]
    do
        sleep 1
    done
done | e2fifout ${NAMED_PIPE_PREFIX}web_fifo.$E2_WEB_PID &
web_thread=$!
fi
#
# ***************************************************************************
# Main program - process user requests until exit
#
while :
do
NOW=`date`
choice=`natmenu 3<<EOF 4>&1 </dev/tty >/dev/tty
HEAD=FILTER:  FILTER Management at $NOW
PROMPT=Select Menu Option and Press RETURN
SEL_YES/COMM_YES/MENU
SCROLL
SESSIONS:    List recent sessions for an IP Address/SESSIONS:
CONSOL:      Consolidated recent sessions for a list of IP Addresses/CONSOL:
QUERYWHOIS:  List WHOIS data we have for an IP Address/QUERYWHOIS:
COUNTRY:     List Country we have for an IP Address/COUNTRY:
MANWHOIS:    Manually add to Whitelist/MANWHOIS:
WHITELIST:   Dump the Whitelist/WHITELIST:
AUTOWHOIS:   Automatically Add to Whitelist - needs ports 43 and 4321/AUTOWHOIS:
DAILYMAIL:   Manually kick off the Daily Mail/DAILYMAIL:
CHECKOK:     Check on disk space and for presence of tcpdump, managesquid.sh and rolling.sh/CHECKOK:
ARBITRARY:   Execute arbitrary shell command as super-user/ARBITRARY:
RESTART:     Restart the monitors/RESTART:
EXIT:        Exit/EXIT:

EOF
`
message_text=
export message_text
case "$choice" in
*EXIT:*)
    break 2
;;
*MANWHOIS:*)
    manwhois
;;
*ARBITRARY:*)
    arbitrary
;;
*AUTOWHOIS:*)
    autowhois
;;
*DAILYMAIL:*)
    dailymail.sh
;;
*CHECKOK:*)
    {
        echo '
Running Status
------------------------------------
Disk space
------------------------------------'
df -k .
echo "Monitoring Processes
------------------------------------"
ps -efww | egrep 'ro[l]ling|tcp[d]ump|manages[q]uid'
    } | output_dispose "CHECKOK: Disk not full, tcpdump, managesquid.sh and rolling.sh present?" 
;;
*RESTART:*)
    killall tcpdump
    ps -ef | gawk '/[r]olling|[m]anagesquid/ { print $2 }' | xargs kill
    rm -f vlan*.trc*
    nohup rolling.sh >/dev/null 2>&1 &
    nohup managesquid.sh >/dev/null 2>&1 &
;;
*QUERYWHOIS:*)
    querywhois
;;
*COUNTRY:*)
    country
;;
*SESSIONS:*)
    sessions
;;
*CONSOL:*)
    consol
;;
*WHITELIST:*)
    sqlite3.8.6 whois.db<< EOF
.output whitelist.lis
select distinct iprange,blocks.rating,blocks.name||','||b.address||','||b.country||','||b.email from blocks
outer join parties b on b.hndle = blocks.owner_hndle where iprange != '-' order by 1;
EOF
    unquote -i -t"|" -m csv whitelist.lis 
    mv csv_whitelist.lis.dat whitelist.csv
(
    html_head=$html_head'<p><a href="whitelist.csv">CSV Format Download</a></p>'
    export html_head
    do_query whois.db "select distinct iprange,blocks.rating,blocks.name||','||b.address||','||b.country||','||b.email from blocks,parties b where iprange != '-' and b.hndle = blocks.owner_hndle order by 1;" "Whitelist"  "IP Range|Rating|ISP Data"
)
;;
*)
message_text="Error: Invalid option : $choice"
        export message_text
;;
esac
done
if [ ! "$MENU_WKB" = tty ]
then
#******************************************************************************
# Closedown
{
echo "$html_head"
echo "<h3>Goodbye!</h3>"
echo $html_tail
}  | e2fifout ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID
sleep 5
rm -f $MENU_HOME/sessions/tmp$E2_WEB_PID.html
if [ ! "$MENU_OS" = NT4 ]
then
    rm -f ${NAMED_PIPE_PREFIX}script_out_fifo.$E2_WEB_PID
    rm -f ${NAMED_PIPE_PREFIX}script_in_fifo.$E2_WEB_PID
    rm -f ${NAMED_PIPE_PREFIX}web_fifo.$E2_WEB_PID
fi
kill -15 $web_thread
fi
exit 
