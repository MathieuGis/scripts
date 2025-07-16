#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

show_system_info() {
    echo -e "${CYAN}========================================"
    echo -e "         SYSTEM INFORMATION"
    echo -e "========================================${NC}"
    printf "${YELLOW}%-20s${NC}: %s\n" "Hostname" "$(hostname)"
    printf "${YELLOW}%-20s${NC}: %s\n" "Operating System" "$(uname -o)"
    printf "${YELLOW}%-20s${NC}: %s\n" "Kernel Version" "$(uname -r)"
    printf "${YELLOW}%-20s${NC}: %s\n" "Architecture" "$(uname -m)"
    printf "${YELLOW}%-20s${NC}: %s\n" "Uptime" "$(uptime -p)"
    printf "${YELLOW}%-20s${NC}: %s\n" "Current User" "$(whoami)"
    printf "${YELLOW}%-20s${NC}: %s\n" "Date & Time" "$(date)"
    echo
}

show_cpu_info() {
    echo -e "${CYAN}========================================"
    echo -e "           CPU INFORMATION"
    echo -e "========================================${NC}"
    lscpu | grep -E 'Model name|Socket|Thread|Core|CPU\(s\):' | awk -F: -v y="$YELLOW" -v n="$NC" '{printf "%s%-20s%s: %s\n", y, $1, n, $2}'
    echo
}

show_memory_info() {
    echo -e "${CYAN}========================================"
    echo -e "         MEMORY INFORMATION"
    echo -e "========================================${NC}"
    free -h | awk -v y="$YELLOW" -v n="$NC" 'NR==1{print y $0 n; next} {print $0}'
    echo
}

show_disk_usage() {
    echo -e "${CYAN}========================================"
    echo -e "            DISK USAGE"
    echo -e "========================================${NC}"
    df -h | column -t | awk -v y="$YELLOW" -v n="$NC" 'NR==1{print y $0 n; next} {print $0}'
    echo
}

show_network_info() {
    echo -e "${CYAN}========================================"
    echo -e "        NETWORK INFORMATION"
    echo -e "========================================${NC}"
    ip -o -4 addr show | awk -v y="$YELLOW" -v n="$NC" '{print y $2 n ": " $4}'
    echo
}

show_logged_in_users() {
    echo -e "${CYAN}========================================"
    echo -e "         LOGGED IN USERS"
    echo -e "========================================${NC}"
    who | awk -v y="$YELLOW" -v n="$NC" '{print y $0 n}'
    echo
}

show_top_processes() {
    echo -e "${CYAN}========================================"
    echo -e "          TOP PROCESSES"
    echo -e "========================================${NC}"
    ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 11 | column -t | awk -v y="$YELLOW" -v n="$NC" 'NR==1{print y $0 n; next} {print $0}'
    echo
}

while true; do
    echo -e "${BLUE}========================================"
    echo -e "           SYSTEM INFO MENU"
    echo -e "========================================${NC}"
    echo -e "${GREEN}1)${NC} System Information"
    echo -e "${GREEN}2)${NC} CPU Information"
    echo -e "${GREEN}3)${NC} Memory Information"
    echo -e "${GREEN}4)${NC} Disk Usage"
    echo -e "${GREEN}5)${NC} Network Information"
    echo -e "${GREEN}6)${NC} Logged In Users"
    echo -e "${GREEN}7)${NC} Top Processes"
    echo -e "${GREEN}8)${NC} Full Report"
    echo -e "${GREEN}9)${NC} Exit"
    read -p "Select an option [1-9]: " choice

    case $choice in
        1) show_system_info ;;
        2) show_cpu_info ;;
        3) show_memory_info ;;
        4) show_disk_usage ;;
        5) show_network_info ;;
        6) show_logged_in_users ;;
        7) show_top_processes ;;
        8)
            show_system_info
            show_cpu_info
            show_memory_info
            show_disk_usage
            show_network_info
            show_logged_in_users
            show_top_processes
            ;;
        9) echo -e "${RED}Exiting...${NC}"; break ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
    esac
done