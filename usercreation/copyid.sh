#!/bin/bash

pass=$1
filelines="$(cat /home/$(whoami)/usercreation/serverlist.txt)"

touch /home/$(whoami)/usercreation/logs/copyid.log

log="/home/$(whoami)/usercreation/logs/copyid.log"

echo "" > $log

	for line in $filelines ; do
	echo "============================================================" >> $log
 	sshpass -p "$pass" ssh-copy-id mathieu@$line >> $log
 	echo "" >> $log
	echo "============================================================" >> $log
	done
clear
cat $log
