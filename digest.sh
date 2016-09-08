#!/bin/bash
# Function to pull together everything we can discover about the IP address
ipdigest() {
allips=$*
export allips
if [ ! -z "$allips" ]
then
echo "begin transaction;" >digestbat.sql
set -x
for ip in $allips
do
#
# Create a compact representation of the whois data
#
    whois $ip | gawk -F: 'NF == 0 {print ""; next}
/^[ 	]/ || /http:\/\// || /https:\/\// { next }
NF == 3 { print $2 ":" $3; next}
/^a. \[Network Number\]/ || /^b. \[Network Name\]/ || /^g. \[Organization\]/ || /^IPv4 Address/ || /^E-Mail/ || /^Service Name/ || /^admin-c/ || /^tech-c/ || /^abuse-c/ || /^Address/ || /^address/ || /^aut-num/ || /^CIDR/ || /^Coordinator/ || /^Country/ || /^country/ || /^CustName/ || /^descr/ || /^e-mail/ || /^holes/ || /^inetnum/ || /^inetnum-up/ || /^irt/ || /^member-of/ || /^Netblock/ || /^NetHandle/ || /^NetName/ || /^Netname/ || /^netname/ || /^NetRange/ || /^NetType/ || /^NetUse/ || /^network/ || /^Network Information/ || /^nic-hdl/ || /^nic-hdl-br/ || /^notify/ || /^org/ || /^OrgAbuseEmail/ || /^OrgAbuseHandle/ || /^organisation/ || /^organization/ || /^OrgID/ || /^OrgId/ || /^OrgName/ || /^org-name/ || /^OrgNOCEmail/ || /^OrgNOCHandle/ || /^OrgTechEmail/ || /^OrgTechHandle/ || /^org-type/ || /^origin/ || /^OriginAS/ || /^owner/ || /^owner-c/ || /^ownerid/ || /^Parent/ || /^parent/ || /^person/ || /^RAbuseEmail/ || /^RAbuseHandle/ || /^Ref/  || /^responsible/ || /^RNOCEmail/ || /^RNOCHandle/ ||  /^role/ || /^route/ || /^RTechEmail/ || /^RTechHandle/ || /^IP-Network/ ||/^Org-Name/ || /^Street-Address/ || /^City/ || /^Postal-Code/ || /^State/ || /^Tech-Email/ || /^Abuse-Email/ || /^%ok/ || /^\[/ { print ; next  }
' >whois.log
    whois=`gawk 'BEGIN {
       if ((getline<"whois.log") > 0)
       {
           whois = $0
           while ((getline<"whois.log") > 0)
           {
               if (length($0) == 0 || $0 ~ /^ *#/)
                   continue
               whois = whois "," $0
           }
           gsub(/[A-Za-z_]+:/,"",whois)
           gsub(/[ 	]+/," ",whois)
           print trim(whois)
       }
}
function trim(x) {
sub(/^[ 	][ 	]*/,"",x)
sub(/[ 	][ 	]*$/,"",x)
gsub("'\''","'\'\''",x)
    return x
}' /dev/null`
#
# Reverse DNS look-up
    nm=`dig -x "$ip" +short | tail -1`
    if [ -z "$nm" ]
    then
        nm=None
    fi
#
# If there have ever been any HTTP sessions, look for Host HTTP headers
    if grep -l "|$ip|[^|]*|80|" traff_*$ip*.log >/dev/null 2>&1
    then
    gawk 'BEGIN { host_seen = ""
       refer_seen = ""
       print_flag = 0
}
function trim(x) {
sub(/^[ 	][ 	]*/,"",x)
sub(/[ 	][ 	]*$/,"",x)
gsub("'\''","'\'\''",x)
    return x
}
/\|'$ip'\|[^|]*\|80\|/ { flag = 1 ; next}
/\|10\.200\./ { flag = 0
    if (host_seen != "" && refer_seen != "")
    {
        print "insert into mailhist( timestamp, ip, revdns, host, refer, whois) values ('$now','\'$ip\'','\'$nm\'','\''" trim(host_seen) "'\'','\''" trim(refer_seen) "'\'','\'"$whois"\'');"
        print_flag = 1
        exit
    }
next
} 
(flag == 1) && /^[Hh][Oo][Ss][Tt]: / { host_seen = substr($2,1,length($2) - 1) }
(flag == 1) && /^[Rr][Ee][Ff][Ee][Rr][Ee][Rr]:/ { refer_seen = substr($2,1,length($2) - 1) }
END { if (print_flag == 1)
        exit
    if (host_seen == "")
        host_seen = "None"
    if ( refer_seen == "")
        refer_seen = "None"
    print "insert into mailhist( timestamp, ip, revdns, host, refer, whois) values ('$now','\'$ip\'','\'$nm\'','\''" trim(host_seen) "'\'','\''" trim(refer_seen) "'\'','\'"$whois"\'');"
}' traff_*$ip*.log
    else
#
# Only HTTPS connections. Attempt to learn something from the certificate
        getcert $ip
        dets=`gawk '/Peer Certificate Name/ {
     n = sub(/.* Peer Certificate Name \(/,"", $0)
     n = sub(/\)/,"", $0)
     print $0
     exit
}
/HTTP\/1.1 504 Gateway Timeout/ { print "Offline"
exit
}' getcert.log`
    savf=`find . -name "traff_*$ip*.log" -print | head -1`
    if [  -z "$savf" ]
    then
        savf=traff_$ip.log
    fi
    cat getcert.log >> $savf
#        echo  $ip $nm  $dets  $whois
        echo "insert into mailhist( timestamp, ip, revdns, host, whois) values ($now,'$ip','$nm','$dets','$whois');"
    fi
done >>digestbat.sql
echo "commit;" >>digestbat.sql
sqlite3 mailhist.db <digestbat.sql
fi
    return
}
