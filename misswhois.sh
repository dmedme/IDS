#!/bin/bash
while read i
do
    echo IP:$i
    torsocks whois $i 2>failed.lis
    if grep Timeout failed.lis >/dev/null 2>&1
    then
        for j in whois.afrinic.net whois.apnic.net whois.lacnic.net whois.arin.net whois.ripe.net
        do
            torsocks whois -h $j $i
        done
    fi
done <uncategorised.lis >misswhois.lis
