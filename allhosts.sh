#!/bin/bash
while read i
do
echo $i `dig -x $i +short`
done <allips.lis >allhosts.lis
