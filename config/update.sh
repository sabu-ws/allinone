#!/bin/bash

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The update script has been executed" >> /sabu/logs/sabu.log


# iptables maintenance
sh /sabu/scripts/network/network-iptables-maintenance.sh

# update sabu
apt update && apt upgrade -y

# iptables prod
sh /sabu/scripts/network/network-iptables-prod.sh

# reboot
reboot

# --- Script By SABU --- #