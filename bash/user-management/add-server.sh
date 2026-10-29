#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="${USER_MANAGEMENT_CONFIG_DIR:-$REPO_ROOT/config/user-management}"
LOG_DIR="${USER_MANAGEMENT_LOG_DIR:-$REPO_ROOT/runtime/user-management}"
mkdir -p -- "$LOG_DIR/newserver"


server=$1

echo "did you make passwordless sudo possible?"
echo ""
echo "hostingpassword? "
read hostingpass

user="$(whoami)"
userlist="$(cat "$CONFIG_DIR/userlist.txt")"
log="$LOG_DIR/newserver/$server.txt"

echo "" > "$log"

sshpass -p "$hostingpass" ssh -o StrictHostKeyChecking=no hosting@$server 'bash -s' < "$SCRIPT_DIR/configure-sudo.sh" "$hostingpass" >> "$log"

for line in $userlist ; do

    name="$(echo $line | cut -d':' -f1)"
    pass="$(echo $line | cut -d':' -f2)"

    echo $name >> "$log"
	
    sshpass -p "$hostingpass" ssh -o StrictHostKeyChecking=no hosting@$server 'bash -s' < "$SCRIPT_DIR/create-user.sh" "$name" "'$pass'" >> "$log"

    echo "done" >> "$log"
    echo "" >> "$log"
    echo "========================================================================================" >> "$log"
    echo "" >> "$log"
done

echo $server >> "$CONFIG_DIR/serverlist.txt"

cat "$log"
