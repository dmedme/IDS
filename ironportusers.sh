#!/bin/bash
# Function to look for users from the Ironport
# 
ironportusers() {
now=$1
export now
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
    cmd = ". $MENU_SOURCE/callironport.sh; ironport_grep 10.200.$MENU_VLAN.75 $MENU_IRONPORT_USER \"$MENU_IRONPORT_PASSWORD\" " rex
    while((cmd|getline) > 0)
        if ($8 != "-")
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
    close(cmd)
    return
}'
return
}
