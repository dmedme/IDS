#!/bin/bash
# ****************************************************************************
# Create a database to hold the hosts and whois information
ab_initio() {
rm -f whois.db
sqlite3 whois.db << EOF
create table hosts (
ip text not null,
ipno integer not null,
name text null);
create table roles_types (
abbr text not null,
descr text not null);
insert into roles_types values ('ABUSE','Abuse Contact');
insert into roles_types values ('TECH','Technical Contact');
insert into roles_types values ('ADMIN','Technical Contact');
insert into roles_types values ('NOC','Network Operations Contact');
insert into roles_types values ('IRT','Incident Response Team');
insert into roles_types values ('OWN','Owner');
insert into roles_types values ('PERSON','Person');
insert into roles_types values ('AS','Autonomous System');
create table blocks (
iprange text not null,
lowipno integer not null,
hiipno integer not null,
name text null,
owner_hndle text null,
rating text null
);
create table geo_blocks (
iprange text not null,
lowipno integer not null,
hiipno integer not null,
country text not null,
rating text null
);
create unique index blocks_i1 on blocks(lowipno,hiipno);
create table parties (
hndle text null,
name text null,
address text null,
country text null,
email text null,
rating text null
);
create table party_roles (
party1_hndle text not null,
party2_hndle text not null,
role_abbr text not null,
email text null
);
EOF
return
}
load_hosts() {
# Load the hosts
gawk -F: 'BEGIN {
# Load the database
print "begin transaction;"
print "delete from hosts;"
last_nf = 1
ip = ""
while ((getline)>0)
{
    if ($1 == "IP")
    {
        if (last_nf == 2)
        {
            print "insert into hosts ( ip, ipno, name) values ("
            printf "'\''%s'\'',%u,null);\n", ip, ipno
        }
        ip = $2
        split(ip,arr,".")
        ipno = arr[1]*256*256*256 + arr[2]*256*256 + arr[3]*256 + arr[4]
        last_nf = NF
    }
    else
    {
        last_nf = NF
        print "insert into hosts ( ip, ipno, name) values ("
        printf "'\''%s'\'',%u,'\''%s'\'');\n", ip, ipno, $1
    }
}
if (ip != "")
{
    print "insert into hosts ( ip, ipno, name) values ("
    printf "'\''%s'\'',%u, null);\n", ip, ipno
}
print "commit;" }' revdns.lis | sqlite3 whois.db
return
}
#
# Geo data, from TOR
#
load_geoip() {
gawk -F, 'BEGIN {
    print "begin transaction;"
}
function getip(ipno) {
    ip = ipno % 256
    ipno = int(ipno/256)
    for (i = 0 ; i < 3; i++)
    {
        ip = (ipno % 256) "." ip
        ipno = int(ipno/256)
    }
    return ip
}
NF == 3 {
    lowip = getip($1)
    hiip = getip($2)
    cntry = $3
    print "insert into geo_blocks ( iprange, lowipno, hiipno, country) values ("
    printf "'\''%s'\'',%u,%u,'\''%s'\'');\n",(lowip "-" hiip),$1,$2,$3
}
END { print "commit;"}' geoip.csv | sqlite3 whois.db
    return
}
#
#
# Now the WHOIS data
#
load_whois() {
whois_data=$1
sqlite3 whois.db << EOF
.output seenranges.lis
select iprange from blocks;
EOF
gawk -F: '(NF == 2 && $1 == "IP") || (NF == 1 && $1 ~ "^[1-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$") {
    if (NF == 1)
        print "IP:" $1
    else
        print $0
    next
}
NF == 0 {print ""; next}
/^[ 	]/ || /http:\/\// || /https:\/\// { next }
NF == 3 { print $2 ":" $3; next}
/^a. \[Network Number\]/ || /^b. \[Network Name\]/ || /^g. \[Organization\]/ || /^IPv4 Address/ || /^E-Mail/ || /^Service Name/ || /^admin-c/ || /^tech-c/ || /^abuse-c/ || /^Address/ || /^address/ || /^aut-num/ || /^CIDR/ || /^Coordinator/ || /^Country/ || /^country/ || /^CustName/ || /^descr/ || /^e-mail/ || /^holes/ || /^inetnum/ || /^inetnum-up/ || /^irt/ || /^member-of/ || /^Netblock/ || /^NetHandle/ || /^NetName/ || /^Netname/ || /^netname/ || /^NetRange/ || /^NetType/ || /^NetUse/ || /^network/ || /^Network Information/ || /^nic-hdl/ || /^nic-hdl-br/ || /^notify/ || /^org/ || /^OrgAbuseEmail/ || /^OrgAbuseHandle/ || /^organisation/ || /^organization/ || /^OrgID/ || /^OrgId/ || /^OrgName/ || /^org-name/ || /^OrgNOCEmail/ || /^OrgNOCHandle/ || /^OrgTechEmail/ || /^OrgTechHandle/ || /^org-type/ || /^origin/ || /^OriginAS/ || /^owner/ || /^owner-c/ || /^ownerid/ || /^Parent/ || /^parent/ || /^person/ || /^RAbuseEmail/ || /^RAbuseHandle/ || /^Ref/  || /^responsible/ || /^RNOCEmail/ || /^RNOCHandle/ ||  /^role/ || /^route/ || /^RTechEmail/ || /^RTechHandle/ || /^IP-Network/ ||/^Org-Name/ || /^Street-Address/ || /^City/ || /^Postal-Code/ || /^State/ || /^Tech-Email/ || /^Abuse-Email/ || /^%ok/ || /^\[/ { print ; next  }
' $whois_data | tee fred.log | gawk -F: 'BEGIN {
    ini_whois()
    print "begin transaction;"
    while((getline<"seenranges.lis")>0)
    {
        used[$0] = 1
    }
    close("seenranges.lis")
}
#
# Format will be in the first instance RIPE or ARIN, but when related values are
# looked up, other server formats are also seen.
#
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
}
/^IP:/ { ini_whois() ; next }
function getipno(ip) {
    split(ip,arr,".")
    return arr[1]*256*256*256 + arr[2]*256*256 + arr[3]*256 + arr[4]
}
/^admin-c/ || /OrgNOCHandle/ || /RNOCHandle/ {
    admin_hndle = trim($2)
    blnk_flag = 0
}
/^tech-c/ || /^OrgTechHandle/ || /RTechHandle/ {
    tech_hndle = trim($2)
    blnk_flag = 0
}
/^abuse-c/ || /^OrgAbuseHandle/ || /RAbuseHandle/ {
    abuse_hndle = trim($2)
    blnk_flag = 0
}
/^e-mail/ || /^notify/ || /OrgNOCEmail/ || /RNOCEmail/ || /^OrgTechEmail/ || /RTechEmail/ || /^OrgAbuseEmail/ || /RAbuseEmail/ || /^Abuse-Email/ || /^Tech-Email/ {
    email = trim($2)
    blnk_flag = 0
}
/^Address/ || /^address/ || /^desc/ || /^NetHandle/ || /^City/ || /^Street-Address/ || /^State/ {
    if (address == "")
        address = trim($2)
    else
        address = address " " trim($2)
    blnk_flag = 0
}
/^aut-num/ || /^OrgID/ || /^owner-c/ || /^owner/ || /^ownerid/ || /^org:/ || /^organi[sz]ation/ || /^origin/ || /^OriginAS/ || /^Parent/ || /^parent/ || /^Service / {
    hndle = trim($2)
    if (owner_hndle == "")
        owner_hndle = hndle
    else
    if (owner_hndle !~ hndle)
        owner_hndle = owner_hndle " " hndle
    blnk_flag = 0
}
/^name/ || /^NetName/ || /^Netname/ || /^Orgname/ || /^person/ || /^irt:/ || /^role/ || /^NetUse/ || /^Org-Name/ || /^Organi[sz]ation/ {
    tname = trim($2)
    if (name == "")
        name = tname
    else
    if (name !~ tname)
        name = name " " tname
    blnk_flag = 0
}
/^a. \[Network Number\]/ {             202.232.212.0/24
    x = trim(substr($0,20))
    do_range(x)
}
/^b. \[Network Name\]/ {
    owner_hndle = trim(substr($0,18))
}
/^g. \[Organization\]/ {
    name = trim(substr($0,18))
    single_block()
}
function do_range(x) {
    if (x ~ /-/)
    {
        split(x, arr, /[ 	]*-[ 	]*/)
        lowip = arr[1]
        hiip = arr[2]
    }
    else
    {
        split(x, arr, "/")
        blk_cnt = 2 ^ (32 - arr[2])
        nf = split(arr[1],arr1,".")
        lowip = arr[1]
        while (nf < 4)
        {
            lowip = lowip ".0"
            nf++
        }
        hiipno = getipno(lowip) + blk_cnt - 1
        hiip = hiipno % 256
        hiipno = int(hiipno/256)
        for (i = 0 ; i < 3; i++)
        {
             hiip = (hiipno % 256) "." hiip
             hiipno = int(hiipno/256)
        }
    }
    return
}
/^CIDR/ || /^inetnum:/ || /^route/ || /^NetRange/ || /^Netblock/ || /^Net-Block/ || /^IPv4 / {
    if (lowip != "" && hiip != "")
        next
    x = trim($2)
    do_range(x)
    if (used[(lowip "-" hiip)] == 1)
        flag = 100
    else
        flag = 0
    blnk_flag = 0
}
/^Country/ || /^country/ {
    country = trim($2)
    blnk_flag = 0
}
NF == 0 {
    if (blnk_flag == 0)
    {
        blnk_flag = 1
        flag++
        if (flag == 2)
        {
            if (owner_hndle == "")
                owner_hndle = (lowip "-" hiip)
            do_block(lowip,hiip, name, owner_hndle)
            used[(lowip "-" hiip)] = 1
            do_parties((lowip "-" hiip),"OWN",owner_hndle,name,address,country,email) 
            name = ""
            address = ""
            email = ""
        }
        else
        if (flag > 2 && flag < 100)
        {
            if (admin_hndle != "")
            {
                do_parties(owner_hndle,"ADMIN",admin_hndle,name,address,country,email) 
                name = ""
                address = ""
                email = ""
                admin_hndle = ""
            }
            else
            if (abuse_hndle != "")
            {
                do_parties(owner_hndle,"ABUSE",abuse_hndle,name,address,country,email) 
                name = ""
                address = ""
                email = ""
                abuse_hndle = ""
            }
            else
            if (tech_hndle != "")
            {
                do_parties(owner_hndle,"TECH",tech_hndle,name,address,country,email) 
                name = ""
                address = ""
                email = ""
                tech_hndle = ""
            }
        }
    }
}
/^\[ Network Information \]/ { next }
/^\[/ {
    if (used[(lowip "-" hiip)] != 1 && flag == 1)
        single_block()
    if (flag < 100)
    {
        split($0, arr, /[ 	][ 	]*/)
        if (arr[2] == "Admin")
            admin_hndle = owner_hndle "-ADMIN"
        else
        if (arr[3] == "Abuse")
            abuse_hndle = owner_hndle "-ABUSE"
        else
        if (arr[2] == "Tech")
            tech_hndle = owner_hndle "-TECH"
    }
}
function single_block() {
    if (used[(lowip "-" hiip)] != 1)
    {
        if (owner_hndle == "")
            owner_hndle = (lowip "-" hiip)
        do_block(lowip,hiip, name, owner_hndle)
        used[(lowip "-" hiip)] = 1
        do_parties((lowip "-" hiip),"OWN",owner_hndle,name,address,country,email) 
    }
}
/^%ok/ {
    single_block()
}
END { print "commit;" }
' | tee fred1.log | sqlite3 whois.db
sqlite3 whois.db << EOF
.output uncategorised.lis
select distinct a.ip from hosts a where not exists (select 'x' from blocks b where a.ipno between b.lowipno and b.hiipno);
EOF
return
}
# *******************************************************
# Function to produce the .bin files used by genconv
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
prepare_bins() {
sqlite3 whois.db << EOF
.output country.lis
select lowipno,hiipno,iprange,rating,country from geo_blocks order by 1,2;
.output whois.lis
select distinct lowipno,hiipno,iprange,blocks.rating,blocks.name||','||b.address||','||b.country||','||b.email from blocks,parties b where iprange != '-' and b.hndle = blocks.owner_hndle order by 1,2;
EOF
/home/e2soft/e2common/ascbin -a -s"|" 2I4 3S <whois.lis >whois.bin
/home/e2soft/e2common/ascbin -a -s"|" 2I4 3S <country.lis >country.bin
    return
}
# ******************************************************
# Main program starts here
# VVVVVVVVVVVVVVVVVVVVVVVV
#ab_initio
#load_hosts
#load_geoip
#sqlite3 whois.db <verio+fpg.sql 
load_whois alerts/alertwhois.lis
prepare_bins
