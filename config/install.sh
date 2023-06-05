#!/bin/bash

# Stand by, process network restart after config in setup page
sleep 5

# Create mountrypoint
sudo mkdir /mnt/usb

# Crontab script
sudo sh /sabu/config/cron.sh

# Install other package
sudo apt install parted ntfs-3g yara clamav exiftool ipcalc nftables -y

# Start and Enable nftables service
sudo systemctl start nftables.service
sudo systemctl enable nftables.service

# Install oletools
git clone https://github.com/decalage2/oletools.git
cd oletools
sudo python3 setup.py install
cd ..
sudo rm -rf oletools/

# Start script iptables prod
sudo sh /sabu/scripts/network/network-nftables-prod.sh

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The installation script has been executed successfully" >> /sabu/logs/sabu.log

# Reboot
sudo reboot

# --- Script By SABU --- #
