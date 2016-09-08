#!/bin/bash
for i in `grep -v '^10\.' allips.lis`
do
echo $i
whois $i
done >allwhois.lis
