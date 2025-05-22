#!/bin/bash
# This script collects server performance statistics and saves them to a file.
# Author: siegewallace06
# Version: 2.0

#### Collect Data ####

# Total CPU Usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Total Memory Usage (Free vs Used Including Percent)
mem_total=$(free -m | awk 'NR==2{printf "%s", $2}')
mem_used=$(free -m | awk 'NR==2{printf "%s", $3}')
mem_free=$(free -m | awk 'NR==2{printf "%s", $4}')
mem_percent=$(free | awk 'FNR == 2 {printf "%.2f", $3/$2 * 100.0}')
mem_used_percent=$(free | awk 'FNR == 2 {printf "%.2f", $3/$2 * 100.0}')
mem_free_percent=$(free | awk 'FNR == 2 {printf "%.2f", $4/$2 * 100.0}')

# Total Disk Usage (Free vs Used Including Percent)
disk_total=$(df -h | awk '$NF=="/"{printf "%d", $2}')
disk_used=$(df -h | awk '$NF=="/"{printf "%d", $3}')
disk_free=$(df -h | awk '$NF=="/"{printf "%d", $4}')
disk_percent=$(df -h | awk '$NF=="/"{printf "%.2f", $3/$2 * 100.0}')
disk_used_percent=$(df -h | awk '$NF=="/"{printf "%.2f", $3/$2 * 100.0}')
disk_free_percent=$(df -h | awk '$NF=="/"{printf "%.2f", $4/$2 * 100.0}')

# Top 5 processes by CPU usage
top_processes=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | tail -n 5)

# Top 5 processes by Memory usage
top_memory_processes=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | tail -n 5)

# OS Information From /etc/os-release
os_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
os_version=$(grep '^VERSION=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
# Kernel Version
kernel_version=$(uname -r)

# Uptime
uptime=$(uptime -p | sed 's/up //')

# System Load Average
load_average=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# Logged In Users
logged_in_users=$(who | wc -l)
# Current Logged In Users
current_logged_in_users=$(who | awk '{print $1}' | sort -u | tr '\n' ' ')

# Failed Login Attempts
failed_login_attempts=$(lastb | wc -l)

# Color codes for output formatting
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

print_section() {
    echo -e "${BLUE}=============================="
    echo -e "$1"
    echo -e "==============================${NC}"
}

print_section "Server Performance Statistics"
printf "${GREEN}%-25s${NC} %s\n" "OS Name:" "$os_name"
printf "${GREEN}%-25s${NC} %s\n" "OS Version:" "$os_version"
printf "${GREEN}%-25s${NC} %s\n" "Kernel Version:" "$kernel_version"
printf "${GREEN}%-25s${NC} %s\n" "Uptime:" "$uptime"
printf "${GREEN}%-25s${NC} %s\n" "Load Average (1/5/15min):" "$load_average"
printf "${GREEN}%-25s${NC} %s\n" "Logged In Users:" "$logged_in_users"
printf "${GREEN}%-25s${NC} %s\n" "Usernames Logged In:" "$current_logged_in_users"
printf "${GREEN}%-25s${NC} %s\n" "Failed Login Attempts:" "$failed_login_attempts"

print_section "CPU Usage"
printf "${GREEN}%-25s${NC} %.2f%%\n" "CPU Usage:" "$cpu_usage"

print_section "Memory Usage"
printf "${GREEN}%-25s${NC} %s MB / %s MB (%.2f%%)\n" "Used Memory:" "$mem_used" "$mem_total" "$mem_used_percent"
printf "${GREEN}%-25s${NC} %s MB (%.2f%%)\n" "Free Memory:" "$mem_free" "$mem_free_percent"

print_section "Disk Usage"
printf "${GREEN}%-25s${NC} %s GB / %s GB (%.2f%%)\n" "Used Disk:" "$disk_used" "$disk_total" "$disk_used_percent"
printf "${GREEN}%-25s${NC} %s GB (%.2f%%)\n" "Free Disk:" "$disk_free" "$disk_free_percent"

print_section "Top 5 Processes by CPU Usage"
echo -e "${top_processes}\n"

print_section "Top 5 Processes by Memory Usage"
echo -e "${top_memory_processes}\n"

print_section "End of Report"
