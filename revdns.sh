#!/bin/bash
while read i
do
echo IP:$i
dig -x $i +short
done <allips.lis >revdns.lis
