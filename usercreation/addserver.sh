#!/bin/bash

server=$1

echo "did you make passwordless sudo possible?"
echo ""
echo "hostingpassword? "
read hostingpass

user="$(whoami)"
userlist="$(cat /home/$user/usercreation/userlist.txt)"
log="/home/$user/usercreation/logs/newserver/$server.txt"

echo "" > $log

sshpass -p "$hostingpass" ssh -o StrictHostKeyChecking=no hosting@$server 'bash -s' < sudofile.sh "$hostingpass" >> $log

for line in $userlist ; do

    name="$(echo $line | cut -d':' -f1)"
    pass="$(echo $line | cut -d':' -f2)"

    echo $name >> $log
	
    sshpass -p "$hostingpass" ssh -o StrictHostKeyChecking=no hosting@$server 'bash -s' < create_user.sh "$name" "'$pass'" >> $log

    echo "done" >> $log
    echo "" >> $log
    echo "========================================================================================" >> $log
    echo "" >> $log
done

echo $server >> /home/$user/usercreation/serverlist.txt

cat $log
