#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="${USER_MANAGEMENT_CONFIG_DIR:-$REPO_ROOT/config/user-management}"
LOG_DIR="${USER_MANAGEMENT_LOG_DIR:-$REPO_ROOT/runtime/user-management}"
mkdir -p -- "$LOG_DIR/newserver"


filelines=`cat "$CONFIG_DIR/serverlist.txt"`
log="$LOG_DIR/logintest.log"
echo "" > "$log"

echo Start

for line in $filelines ; do
echo $line
echo "==================================================================" >> "$log"
echo "" >> "$log"
echo $line >> "$log"
echo "" >> "$log"

ssh mathieu@$line 'sudo -l' | grep "ALL" >> "$log"
echo "" >> "$log"
echo 'done'
done
