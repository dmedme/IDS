#!/bin/bash
# ****************************************************************************
# Create an SQLITE database to hold the network flow information
rm -f netmap.db
sqlite3 netmap.db << EOF
create table sites (
site text not null,
name text null);
create table hosts (
ip text not null,
name text null,
site text null);
create table links (
ip1 text not null,
ip2 text not null);
create table paths (
ip1 text not null,
ip2 text not null,
len int);
create table path_links (
path_rowid integer,
link_rowid integer,
seq int);
create table link_flows (
link_rowid integer,
datetime timestamp,
bytes integer);
create table path_flows (
path_rowid integer,
datetime timestamp,
bytes integer);
create table router_data (
ip text,
ts datetime,
li text,
desc text,
bytes_in integer,
packets_in integer,
bytes_out integer,
packets_out integer,
utilisation_in double,
utilisation_out double,
errs integer);
EOF
#
# Load the hosts
#
gawk -F"|" 'BEGIN {
    site["an"] = "an"
    site["al"] = "al"
    site["ch"] = "ch"
    site["cv"] = "cv"
    site["ds"] = "ds"
    site["eh"] = "eh"
    site["gk"] = "gk"
    site["gl"] = "gl"
    site["hq"] = "hq"
    site["is"] = "is"
    site["kk"] = "kk"
    site["lm"] = "lm"
    site["ph"] = "ph"
    site["pd"] = "pd"
    site["pt"] = "pt"
    site["ss"] = "ss"
    site["sc"] = "sc"
    site["ms"] = "ms"
    print "begin transaction;"
    print "insert into sites (site,name) values ('\''an'\'', '\''Aberdeen'\'');"
    print "insert into sites (site,name) values ('\''al'\'', '\''Addiewell'\'');"
    print "insert into sites (site,name) values ('\''ch'\'', '\''Castle Huntly'\'');"
    print "insert into sites (site,name) values ('\''cv'\'', '\''Cornton Vale'\'');"
    print "insert into sites (site,name) values ('\''ds'\'', '\''Dumfries'\'');"
    print "insert into sites (site,name) values ('\''eh'\'', '\''Edinburgh'\'');"
    print "insert into sites (site,name) values ('\''gk'\'', '\''Greenock'\'');"
    print "insert into sites (site,name) values ('\''gl'\'', '\''Glenochil'\'');"
    print "insert into sites (site,name) values ('\''hq'\'', '\''Headquarters'\'');"
    print "insert into sites (site,name) values ('\''is'\'', '\''Inverness'\'');"
    print "insert into sites (site,name) values ('\''kk'\'', '\''Kilmarnock'\'');"
    print "insert into sites (site,name) values ('\''lm'\'', '\''Low Moss'\'');"
    print "insert into sites (site,name) values ('\''ms'\'', '\''Mirror Site (Hamilton)'\'');"
    print "insert into sites (site,name) values ('\''ph'\'', '\''Perth'\'');"
    print "insert into sites (site,name) values ('\''pd'\'', '\''Peterhead'\'');"
    print "insert into sites (site,name) values ('\''pt'\'', '\''Polmont'\'');"
    print "insert into sites (site,name) values ('\''cs'\'', '\''Central Stores'\'');"
    print "insert into sites (site,name) values ('\''ss'\'', '\''Shotts'\'');"
}
{
    x = site[tolower(substr($2,1,2))]
    if (x == "")
        x = "hq"
    if ($2 == "" || substr($2,1,4) == "SOA:")
        name = "Unspecified"
    else
        name = $2
    print "insert into hosts (ip, name, site) values ('\''" $1 "'\'','\''" name "'\'','\''" x "'\'');"
}
END {
    print "commit;"
}' spshosts.lis | sqlite3 netmap.db
#
# Create a list of links from the traceroute data and load that
#
#>otherhosts.lis
gawk '/Nmap scan report for/ {
    if (NF == 5)
        ip = $5
    else
        ip = substr($6,2,length($6) - 2)
    next
}
/TRACEROUTE/ {
    prev = ""
    curr = ""
#    print $0>>"trace.log"
    getline
#    print $0>>"trace.log"
    for (;;)
    {
        if ((getline)<1)
            exit
#        print $0>>"trace.log"
        if (NF > 3)
            break
    }
    ky = ""
    if ($1 ~ /[1-9][0-9]*/)
    {
        if (NF == 4)
            prev = $4
        else
        if (NF == 5)
        {
            prev = substr($5,2,length($5) - 2)
#            print prev "|" $4 >>"otherhosts.lis"
        }
        hop[ ip ":" $1 ] = prev
        if (miss[ ip ":" $1 ] != "")
        {
#            print "Found:miss[" ip ":" $1 "] = " miss[ ip ":" $1]
            for (i = split( miss[ ip ":" $1 ], arr, ":"); i > 0; i--)
                print prev "|" arr[i]
            miss[ ip ":" $1 ] = ""
        }
    }
    else
    {
        if ($2 == "Hop")
        {
            ky = $9 ":" $3
            prev = hop[ ky ]
            nf = 1
            arr1[1] = 1
            if (prev != "")
                hop[ ip ":1" ] = prev
        }
        else
        if ($2 == "Hops")
        {
            nf = split($3,arr1,"-")
            ky = $9 ":" arr1[2]
            prev = hop[ ky ]
            if (prev != "")
                hop[ ip ":" arr1[2] ] = prev
        }
        for (i = 1; i <= nf; i++)
        {
            if (hop[ $9 ":" i ] != "")
            {
                if (i < nf)
                    hop[ ip ":" i ] = hop[ $9 ":" i]
                if ( miss[ ip ":" i] != "")
                {
#                    print "Redirect found:miss[" ip ":" i "] = " miss[ ip ":" i]
                    for (j = split( miss[ ip ":" i ], arr, ":"); j > 0; j--)
                        print hop[ $9 ":" i] "|" arr[j]
                    miss[ ip ":" i ] = ""
                }
            }
            else
            if ( miss[ ip ":" i] != "")
            {
                if (miss[ $9 ":" i ] != "")
                    miss[ $9 ":" i ] = miss[ $9 ":" i ] ":" miss[ ip ":" i]
                else
                    miss[ $9 ":" i ] = miss[ ip ":" i]
#                print "Combined:miss[" $9 ":" i "] = " miss[ $9 ":" i]
            }
        }
    }
    while((getline)> 0 && NF > 0)
    {
#        print $0>>"trace.log"
        if (NF < 4)
            continue
        if (NF == 4)
            curr = $4
        else
        if (NF == 5)
        {
            curr = substr($5,2,length($5) - 2)
        }
        if (miss[ ip ":" $1 ] != "")
        {
#            print "Found:miss[" ip ":" $1 "] = " miss[ ip ":" $1]
            for (i = split( miss[ ip ":" $1 ], arr, ":"); i > 0; i--)
                print curr "|" arr[i]
            miss[ ip ":" $1 ] = ""
        }
        hop[ ip ":" $1 ] = curr
        if (prev != "" && curr != "")
            print prev "|" curr
        if (prev == "")
        {
            if (miss[ky] == "")
                miss[ky] = curr
            else
                miss[ky] = miss[ky] ":" curr
#            print "Update:miss[" ky "] = " miss[ ky]
        }
        
        if (curr != "")
            prev = curr
    }
#    print ip>>"seen.lis"
}
/nbstat/ {
#    print ip "|" substr($4,1,length($4)-1) >>"otherhosts.lis"
}' nmap.txt | gawk -F"|" '{
    if ($1 == $2)
        next
    if ($1 > $2)
        print $2 "|" $1
    else
        print $0
}' | sort | uniq |
gawk -F"|" 'BEGIN {
    print "begin transaction;"
}
{
    print "insert into links (ip1, ip2) values (\"" $1 "\",\"" $2 "\");"
    print "insert into links (ip1, ip2) values (\"" $2 "\",\"" $1 "\");"
}
END {
    print "commit;"
}' | sqlite3 netmap.db
#
# Construct some useful indices
#
sqlite3 netmap.db << EOF
create index site_name on sites(name);
create index hosts_ip on hosts(ip);
create index hosts_site_ip on hosts(site,ip);
create index links_ip1_ip2 on links(ip1,ip2);
EOF
