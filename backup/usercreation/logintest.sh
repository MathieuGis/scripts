#!/bin/bash

filelines=`cat /home/mathieu/usercreation/serverlist.txt`
log='/home/mathieu/usercreation/logs/logintest.log'
echo "" > $log

echo Start

for line in $filelines ; do
echo $line
echo "==================================================================" >> $log
echo "" >> $log
echo $line >> $log
echo "" >>  $log

ssh mathieu@$line 'sudo -l' | grep "ALL" >> $log
echo "" >> $log
echo 'done'
done
