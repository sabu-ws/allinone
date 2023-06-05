#!/bin/bash

# RETRIEVE NETWORK INFORMATION
interface=$(jq '.network | .interface' /sabu/config/config.json  | tr -d '"')
address=$(jq '.network | .ip' /sabu/config/config.json  | tr -d '"')
netmask=$(jq '.network | .netmask' /sabu/config/config.json  | tr -d '"')
nameserver1=$(jq '.network | .dns1' /sabu/config/config.json  | tr -d '"')
nameserver2=$(jq '.network | .dns2' /sabu/config/config.json  | tr -d '"')

# CALCULATE NETWORK
network=$(ipcalc $address/$netmask | grep "Network" | cut -d' ' -f4)

# FLUSH TABLE
iptables -F

# INPUT RULES
## acces_ssh
iptables -A INPUT -p tcp -i $interface --src $network --dst $address --dport 22 -j ACCEPT
## connexion_http
iptables -A INPUT -p tcp -i $interface --src $network --dst $address --dport 80 -j ACCEPT
## connexion_https
iptables -A INPUT -p tcp -i $interface --src $network --dst $address --dport 443 -j ACCEPT
## drop_all
iptables -A INPUT -i $interface --src 0.0.0.0/0 --dst $address -j DROP

# OUTPUT RULES
## acces_ssh
iptables -A OUTPUT -p tcp --src $address --dst $network -j ACCEPT
## connexion_http
iptables -A OUTPUT -p tcp --src $address --dst 0.0.0.0/0 --dport 80 -j ACCEPT
## connexion_https
iptables -A OUTPUT -p tcp --src $address --dst 0.0.0.0/0 --dport 443 -j ACCEPT
## drop_all
iptables -A OUTPUT --src $address --dst 0.0.0.0/0 -j DROP

# SAVE 
sudo iptables-save > /etc/iptables/rules.v4

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [NETWORK][Iptables] Rule 'iptables-prod' enabled" >> /sabu/logs/network.log

# --- Script By SABU --- #
