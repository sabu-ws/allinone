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
## Allow SSH
sudo nft add rule inet filter input iif $interface ip saddr $network ip daddr $address tcp dport 22 accept
## Allow HTTP
sudo nft add rule inet filter input iif $interface ip saddr $network ip daddr $address tcp dport 80 accept
## Allow HTTPS
sudo nft add rule inet filter input iif $interface ip saddr $network ip daddr $address tcp dport 443 accept
## DROP ALL
sudo nft add rule inet filter input iif $interface ip saddr 0.0.0.0/0 ip daddr $address drop

# OUTPUT RULES
## Allow SSH
sudo nft add rule inet filter output oif $interface ip saddr $address tcp sport 22 ip daddr $network accept
## Allow HTTP
sudo nft add rule inet filter output oif $interface ip saddr $address tcp sport 80 ip daddr 0.0.0.0/0 accept
## Allow HTTPS
sudo nft add rule inet filter output oif $interface ip saddr $address tcp sport 443 ip daddr 0.0.0.0/0 accept
## DROP ALL
sudo nft add rule inet filter output oif $interface ip saddr $address ip daddr 0.0.0.0/0 drop

# SAVE POLICY
sudo nft list ruleset > /etc/nftables.conf

# RESTART SERVICE NFTABLES
sudo systemctl restart nftables.service

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [NETWORK][nftables] Policy 'nftables-prod' enabled" >> /sabu/logs/network.log

# --- Script By SABU --- #
