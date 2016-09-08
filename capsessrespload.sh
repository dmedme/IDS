#!/bin/bash
rm -f capsessresp.db
sqlite3 capsessresp.db << EOF
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
create table capresp (
resp_start datetime not null,
sip varchar(16) not null,
sport integer null,
dip varchar(16) not null,
dport integer null,
pout int64,
pin int64,
bout int64,
bin int64,
resp double,
desc varchar(256));
EOF
#
# Load the sessions round the same way
#
gawk -F"|" '/\|Session / {
# 7 Mar 2012 13:35:24.573569|Session Complete|02:01:0a:7d:14:bb|00:19:b9:f6:b7:74|TCP|10.125.20.178|10.125.20.188|1602|2312|16|24|5242|6416|0|0|0.000176|0.002263|0.006866|0.000105|
    if (substr($6,1,10) == "10.110.65.")
        print $1 "|" $2 "|" $4 "|" $3 "|" $5 "|" $7 "|" $6 "|" $9 "|" $8 "|" $11 "|" $10 "|" $13 "|" $12 "|" $15 "|" $14 "|" $19 "|" $18 "|" $17 "|" $16 "|"
    else
        print $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17 "|" $18 "|" $19 "|"
}' dbserv_sess.txt | sort -t"|" -k 6,6 -k 8,8 -k 7,7 -k 9,9 -k 1,1 | gawk -F "|" '{
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
END { print "commit;" }' | sqlite3 capsessresp.db
exit
#
# Load the response times
#
gawk -F"|" ' BEGIN {
# Load the database
# Sample - 00:1e:13:26:91:00|00:1d:a1:8b:95:a8|TCP|10.110.17.169|10.110.65.152|1433|1240|RESPONSE|00|1383817731.740320|29.204583|2|2|120|120| 7 Nov 2013 09:48:51.740320|
print "begin transaction;"
}
/\|RESPONSE|/ {
    print "insert into capresp ( resp_start, sip, sport, dip, dport, pout, pin, bout, bin, resp, desc) values ("
    printf "'\''%s'\'','\''%s'\'',%d,'\''%s'\'',%d, %d, %d, %u, %u, %f, '\''%s'\'');\n", $16, $4, $6, $5, $7, $12, $13, $14, $15, $11, $9
}
END { print "commit;" }' resp.log | sqlite3 capsessresp.db
sqlite3 capsessresp.db << EOF
create index sess_start_ix on capsess (
sess_start);
create index capsess_dport_ix on capsess (
dport);
create index capresp_dport_ix on capresp (
dport);
create index resp_start_ix on capresp (
resp_start);
create index desc_ix on capresp (
desc);
EOF
