#!/bin/bash

filelines="$(cat /home/mathieu/usercreation/serverlist.txt)"
testfile="$(cat /home/mathieu/usercreation/testfile.txt)"
log="/home/$(whoami)/usercreation/logs/pass_change.log"

user="$1"
pass="$2"
passH="$(mkpasswd -m SHA-512 $2)"
replace="$(cat /home/$(whoami)/usercreation/userlist.txt | grep $user)"

echo "did you fill in correct  user/pass ?"
echo "user: $user"
echo "pass: $pass"

read -n1 -r -p " Press any key to continue..." key

echo "" > $log
echo Start

for line in $filelines ; do
    echo $line
    echo "==================================================================" >> $log
    echo "" >> $log
    echo $line >> $log
    echo "" >>  $log

    ssh $(whoami)@$line "echo $user:$pass | sudo chpasswd" >> $log

    echo "" >> $log
    echo 'done'
done

sed -i "s~$replace~$user:$passH~g" /home/$(whoami)/usercreation/userlist.txt
