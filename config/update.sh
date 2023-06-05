#!/bin/bash

# iptables maintenance
sudo sh /sabu/scripts/network/network-nftables-maintenance.sh

# update sabu
sudo apt update && sudo apt upgrade -y

# update clamav databases
sudo systemctl stop clamav-freshclam.service
sudo freshclam -d
sleep 3
sudo systemctl start clamav-freshclam.service

# iptables prod
sudo sh /sabu/scripts/network/network-nftables-prod.sh

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The update script has been executed" >> /sabu/logs/sabu.log

# reboot
sudo reboot

# --- Script By SABU --- #