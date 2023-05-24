#!/bin/bash

# Arguments
## $1 = address
## $2 = netmask
## $3 = gateway
## $4 = domain-server1
## $5 = domain-server2

# RETRIEVE NETWORK INTERFACE
interface=$(ip -br a | awk '{print $1}' | grep -wv lo)

# Retrieve the line number of the network interface
lignes=$(grep -n $interface /etc/network/interfaces | tail -n +2 | cut -d ':' -f1)

# Change the network information in relation to the arguments
sed -i "$(($lignes+1))c\address $1" /etc/network/interfaces
sed -i "$(($lignes+2))c\netmask $2" /etc/network/interfaces
sed -i "$(($lignes+3))c\gateway $3" /etc/network/interfaces
sed -i "1c\nameserver $4" /etc/resolv.conf
sed -i "2c\nameserver $5" /etc/resolv.conf

# Restart the network configuration
systemctl restart networking.service

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [NETWORK][Interface] The network interface has been configured" >> /sabu/logs/network.log

# --- Script By SABU --- #
