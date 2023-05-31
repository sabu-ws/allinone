#!/bin/bash

# Create mountrypoint
mkdir /mnt/usb

# Crontab script update at 2 AM
echo "0 2 * * * sh /sabu/config/update.sh" >> crontab -e 

# Install other package
apt install parted mkfs ntfs-3g dd yara clamav exiftools ipcalc iptables -y
echo iptables-persistent iptables-persistent/autosave_v4 boolean false | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | debconf-set-selections
apt install iptables-persistent -y

# Install oletools
git clone https://github.com/decalage2/oletools.git
cd oletools
python3 setup.py install
cd ..
rm -rf oletools/

# Start script iptables prod
sh /sabu/scripts/network/network-iptables-prod.sh

# Reboot
reboot

# --- Script By SABU --- #
