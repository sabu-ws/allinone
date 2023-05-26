#!/bin/bash

# crontab script update at 2 AM
 echo "0 2 * * * sh /sabu/config/update.sh" >> crontab -e 

# install package
apt install parted mkfs ntfs-3g dd yara clamav exiftools ipcalc iptables -y

# start script iptables prod
sh /sabu/scripts/network/network-iptables-prod.sh

# Reboot SABU
reboot