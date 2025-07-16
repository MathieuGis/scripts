#!/bin/bash

show_system_info() {
    echo "========================================"
    echo "         SYSTEM INFORMATION"
    echo "========================================"
    printf "%-20s: %s\n" "Hostname" "$(hostname)"
    printf "%-20s: %s\n" "Operating System" "$(uname -o)"
    printf "%-20s: %s\n" "Kernel Version" "$(uname -r)"
    printf "%-20s: %s\n" "Architecture" "$(uname -m)"
    printf "%-20s: %s\n" "Uptime" "$(uptime -p)"
    printf "%-20s: %s\n" "Current User" "$(whoami)"
    printf "%-20s: %s\n" "Date & Time" "$(date)"
    echo
}

show_cpu_info() {
    echo "========================================"
    echo "           CPU INFORMATION"
    echo "========================================"
    lscpu | grep -E 'Model name|Socket|Thread|Core|CPU\(s\):' | awk -F: '{printf "%-20s: %s\n", $1, $2}'
    echo
}

show_memory_info() {
    echo "========================================"
    echo "         MEMORY INFORMATION"
    echo "========================================"
    free -h
    echo
}

show_disk_usage() {
    echo "========================================"
    echo "            DISK USAGE"
    echo "========================================"
    df -h | column -t
    echo
}

show_network_info() {
    echo "========================================"
    echo "        NETWORK INFORMATION"
    echo "========================================"
    ip -o -4 addr show | awk '{print $2 ": " $4}'
    echo
}

show_logged_in_users() {
    echo "========================================"
    echo "         LOGGED IN USERS"
    echo "========================================"
    who
    echo
}

show_top_processes() {
    echo "========================================"
    echo "          TOP PROCESSES"
    echo "========================================"
    ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 11 | column -t
    echo
}

while true; do
    echo "========================================"
    echo "           SYSTEM INFO MENU"
    echo "========================================"
    echo "1) System Information"
    echo "2) CPU Information"
    echo "3) Memory Information"
    echo "4) Disk Usage"
    echo "5) Network Information"
    echo "6) Logged In Users"
    echo "7) Top Processes"
    echo "8) Exit"
    read -p "Select an option [1-8]: " choice

    case $choice in
        1) show_system_info ;;
        2) show_cpu_info ;;
        3) show_memory_info ;;
        4) show_disk_usage ;;
        5) show_network_info ;;
        6) show_logged_in_users ;;
        7) show_top_processes ;;
        8) echo "Exiting..."; break ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done