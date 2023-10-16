#!/bin/bash

hostname=$(hostname)
date=$(date +"%d-%m-%Y %H:%M:%S")
timezone=$(cat /etc/timezone)
#uptime=$(uptime | awk '{print $3,$4}' | tr -d ',')
uptime=$(uptime -s)

total_space=$(df -h / | awk '{print $2}' | tail -n1)
used_space=$(df -h / | awk '{print $3}' | tail -n1)
percentage=$(df -h / | awk '{print $5}' | tail -n1)

# Hostname
echo $hostname
# System time
echo $date 
# System timezon
echo $timezone
# System uptime
echo $uptime
# System used_space
echo "$used_space / $total_space ($percentage)"