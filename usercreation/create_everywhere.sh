#!/bin/bash

user="$(whoami)"
filelines="$(cat /home/$user/usercreation/serverlist.txt)"
log="/home/$user/usercreation/logs/creation.log"
username="$1"
pass="$2"
passH="$(mkpasswd -m SHA-512 $2)"

clear

if [ -z "$username" ] || [ -z "$pass" ];
then
	echo "you forgot to set username/pass!"
	exit
else

	echo ""
	echo "  user: $username"
	echo "  pass: $pass"
	echo ""

	read -n1 -r -p " Are these correct? Press any key to continue..." key

	echo "" > $log

	echo $username:$passH >> /home/$user/usercreation/userlist.txt

	echo Start

	for line in $filelines ; do
	
		echo $line
		echo "==================================================================" >> $log
		echo "" >> $log
		echo $line >> $log
		echo "" >>  $log

		ssh $user@$line 'bash -s' < create_user.sh $username "'$passH'" >> $log
	
		echo "" >> $log
		echo 'done'
	done
fi
