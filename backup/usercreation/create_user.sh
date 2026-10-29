#!/bin/bash
ROOT_UID=0
SUCCESS=0
E_USEREXISTS=70

username="$1"
pass=$2

if [ -z "$username" ] || [ -z "$pass" ];
then
    echo "vars not set correct!"
    exit
else

	grep -q "$username" /etc/passwd
	if [ $? -eq $SUCCESS ] 
	then	
		echo "User $username does already exist."
		echo "please chose another username."
		exit $E_USEREXISTS
	fi  

	sudo apt-get install whois > /dev/null 2>&1
	sudo useradd -p "$pass" -d /home/"$username" -m -g users -s /bin/bash "$username"
	sudo adduser $username sudo

	echo "the account is setup"
   exit 0
fi

