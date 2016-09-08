#!/bin/bash
gawk '{ for (i = 1; i <= NF; i++)
    if ($i ~ /^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/)
        print $i
}' squidhosts.lis | sort | uniq | tee squidips.lis | while read i
do
   echo IP:$i `dig -x $i +short`
   whois $i
done >squidwhois.lis
