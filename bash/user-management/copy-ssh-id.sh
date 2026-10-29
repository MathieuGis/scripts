#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="${USER_MANAGEMENT_CONFIG_DIR:-$REPO_ROOT/config/user-management}"
LOG_DIR="${USER_MANAGEMENT_LOG_DIR:-$REPO_ROOT/runtime/user-management}"
mkdir -p -- "$LOG_DIR/newserver"


pass=$1
filelines="$(cat "$CONFIG_DIR/serverlist.txt")"

touch "$LOG_DIR/copyid.log"

log="$LOG_DIR/copyid.log"

echo "" > "$log"

	for line in $filelines ; do
	echo "============================================================" >> "$log"
 	sshpass -p "$pass" ssh-copy-id mathieu@$line >> "$log"
 	echo "" >> "$log"
	echo "============================================================" >> "$log"
	done
clear
cat "$log"
