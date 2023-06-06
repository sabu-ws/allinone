#!/bin/bash

# Stand by, process network restart after config in setup page
sleep 5

# Set up automount
sudo cp /sabu/udev/01-automount-usb-key.rules /etc/udev/rules.d/01-automount-usb-key.rules
sudo cp /sabu/service/usb-automount@.service /etc/systemd/system/usb-automount@.service

sudo systemctl daemon-reload
sudo systemctl start usb-automount@.service
sudo systemctl enable usb-automount@.service

sudo udevadm control --reload-rules


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

# --- Script By SABU --- #
