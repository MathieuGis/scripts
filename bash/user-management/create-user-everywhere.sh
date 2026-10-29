#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="${USER_MANAGEMENT_CONFIG_DIR:-$REPO_ROOT/config/user-management}"
LOG_DIR="${USER_MANAGEMENT_LOG_DIR:-$REPO_ROOT/runtime/user-management}"
mkdir -p -- "$LOG_DIR/newserver"


user="$(whoami)"
filelines="$(cat "$CONFIG_DIR/serverlist.txt")"
log="$LOG_DIR/creation.log"
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

	echo "" > "$log"

	echo $username:$passH >> "$CONFIG_DIR/userlist.txt"

	echo Start

	for line in $filelines ; do
	
		echo $line
		echo "==================================================================" >> "$log"
		echo "" >> "$log"
		echo $line >> "$log"
		echo "" >> "$log"

		ssh $user@$line 'bash -s' < "$SCRIPT_DIR/create-user.sh" $username "'$passH'" >> "$log"
	
		echo "" >> "$log"
		echo 'done'
	done
fi
