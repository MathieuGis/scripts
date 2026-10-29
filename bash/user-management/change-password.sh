#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="${USER_MANAGEMENT_CONFIG_DIR:-$REPO_ROOT/config/user-management}"
LOG_DIR="${USER_MANAGEMENT_LOG_DIR:-$REPO_ROOT/runtime/user-management}"
mkdir -p -- "$LOG_DIR/newserver"


filelines="$(cat "$CONFIG_DIR/serverlist.txt")"
log="$LOG_DIR/pass_change.log"

user="$1"
pass="$2"
passH="$(mkpasswd -m SHA-512 $2)"
replace="$(cat "$CONFIG_DIR/userlist.txt" | grep $user)"

echo "did you fill in correct  user/pass ?"
echo "user: $user"
echo "pass: $pass"

read -n1 -r -p " Press any key to continue..." key

echo "" > "$log"
echo Start

for line in $filelines ; do
    echo $line
    echo "==================================================================" >> "$log"
    echo "" >> "$log"
    echo $line >> "$log"
    echo "" >> "$log"

    ssh $(whoami)@$line "echo $user:$pass | sudo chpasswd" >> "$log"

    echo "" >> "$log"
    echo 'done'
done

sed -i "s~$replace~$user:$passH~g" "$CONFIG_DIR/userlist.txt"
