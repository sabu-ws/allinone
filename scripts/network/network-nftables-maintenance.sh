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
sudo nft flush ruleset

# ADD TABLE
sudo nft add table inet filter

# ADD CHAIN (INPUT/OUTPUT) IN TABLE
sudo nft add chain inet filter input { type filter hook input priority 0\; }
sudo nft add chain inet filter output { type filter hook output priority 0\; }

# INPUT RULES
## acces_ssh
sudo nft add rule inet filter input iif $interface ip saddr $network ip daddr $address tcp dport 22 accept
## connexion_dns
sudo nft add rule inet filter input iif $interface ip saddr $nameserver1 ip daddr $address udp dport 53 accept
sudo nft add rule inet filter input iif $interface ip saddr $nameserver2 ip daddr $address udp dport 53 accept
## connexion_tcp_established
sudo nft add rule inet filter input iif $interface ip saddr 0.0.0.0/0 ip daddr $address ct state established accept
## drop_all
sudo nft add rule inet filter input iif $interface ip saddr 0.0.0.0/0 ip daddr $address drop

# OUTPUT RULES
## acces_ssh
sudo nft add rule inet filter output oif $interface ip saddr $address tcp sport 22 ip daddr $network accept
## connexion_dns
sudo nft add rule inet filter output oif $interface ip saddr $address ip daddr $nameserver1 udp dport 53 accept
sudo nft add rule inet filter output oif $interface ip saddr $address ip daddr $nameserver2 udp dport 53 accept
## connexion_http
sudo nft add rule inet filter output oif $interface ip saddr $address ip daddr 0.0.0.0/0 tcp dport 80 accept
## connexion_https
sudo nft add rule inet filter output oif $interface ip saddr $address ip daddr 0.0.0.0/0 tcp dport 443 accept
## drop_all
sudo nft add rule inet filter output oif $interface ip saddr $address ip daddr 0.0.0.0/0 drop

# SAVE POLICY
sudo nft list ruleset > /etc/nftables.conf

# RESTART SERVICE NFTABLES
sudo systemctl restart nftables.service

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [NETWORK][nftables] Policy 'nftables-maintenance' enabled" >> /sabu/logs/network.log

# --- Script By SABU --- #
