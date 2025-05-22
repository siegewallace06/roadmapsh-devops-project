#!/bin/bash

# This script collects server performance statistics and displays them in a user-friendly format for analysis purposes.
# Author: siegewallace06

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

### Display Data ###
# Display the collected data in a user-friendly format
echo "=============================="
echo " Server Performance Statistics "
echo "=============================="
echo "OS Name: $os_name"
echo "OS Version: $os_version"
echo "Kernel Version: $kernel_version"
echo "Uptime: $uptime"
echo "Load Average (1, 5, 15 min): $load_average"
echo "Logged In Users: $logged_in_users"
echo "Current Logged In Users: $current_logged_in_users"
echo "Failed Login Attempts: $failed_login_attempts"

echo "=============================="
echo " CPU Usage: $cpu_usage%"
echo "=============================="
echo " Memory Usage: $mem_used MB / $mem_total MB ($mem_used_percent%)"
echo " Free Memory: $mem_free MB ($mem_free_percent%)"
echo "=============================="
echo " Disk Usage: $disk_used GB / $disk_total GB ($disk_used_percent%)"
echo " Free Disk Space: $disk_free GB ($disk_free_percent%)"
echo "=============================="
echo " Top 5 Processes by CPU Usage:"
echo "$top_processes"
echo "=============================="
echo " Top 5 Processes by Memory Usage:"
echo "$top_memory_processes"
echo "=============================="
echo " End of Report "
echo "=============================="
