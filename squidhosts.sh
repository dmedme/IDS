#!/bin/bash
while read i
do
echo `dig $i +short` $i
done <squidnames.lis >squidhosts.lis
