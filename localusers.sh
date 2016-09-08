#!/bin/bash
# Function to look for users in our copies of the Ironport logs
# 
localusers() {
now=$1
export now
set -x
#
# Pass 1 - pull out all the Squid records we have
#
sqlite3 mailhist.db "select ip,revdns,host from mailhist where timestamp=$now;" |
gawk -F"|" '{
    ip=$1
    revdns=$2
    host=$3
    print ip
    if (host != "" && host != "Offline" && host != "None")
    {
        if (host ~ /CN=/)
            sub(/.*CN=\**/,"",host)
    }
    else
    if (revdns != "" && revdns != "Offline" && revdns != "None")
        host = revdns
    else
        host = ""
    if (host != "")
        print host
}' > squidhunt.lis
grep -F -f squidhunt.lis -h $MENU_HOME/squid/aclog.*.s >squid.lis
#
# Pass 2 - pull out just the ones for each IP and host, and update the table
sqlite3 mailhist.db "select ip,revdns,host from mailhist where timestamp=$now;" |
gawk -F"|" '{
    ip=$1
    revdns=$2
    host=$3
    users=""
    repute=""
    FS = " "
    getusers(ip)
    if (host != "" && host != "Offline" && host != "None")
    {
        if (host ~ /CN=/)
            sub(/.*CN=\**/,"",host)
    }
    else
    if (revdns != "" && revdns != "Offline" && revdns != "None")
        host = revdns
    else
        host = ""
    if (host != "")
        getusers(host)
    if (users != "")
    {
        gsub("\\","\\\\",users)
        gsub("\"","\\\"",users)
        gsub("\\","\\\\",repute)
        gsub("\"","\\\"",repute)
        system("sqlite3 mailhist.db \"update mailhist set users='\''" users "'\'', category = '\''" repute "'\'' where ip='\''" ip "'\'' and timestamp = '$now';\"")
    }
    FS = "|"
}
function getusers(rex) {
    while((getline<"squid.lis") > 0)
        if ($8 != "-" && $0 ~ rex)
        {
            if ( repute == "")
                repute = $12
            else
            if (!index(repute, $12))
                repute = repute " " $12
            if (users == "")
                users = $8 " " $3
            else
            {
                if (!index(users, $8))
                    users = users " " $8
                if (!index(users, $3))
                    users = users " " $3
            }
        }
    close("squid.lis")
    return
}'
return
}
