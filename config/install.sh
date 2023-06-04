#!/bin/bash

# Stand by, process network restart after config in setup page
sleep 5

# Create mountrypoint
mkdir /mnt/usb

# Crontab script
echo "@reboot sh /sabu/config/check.sh" >> crontab -e 
echo "0 2 * * * sh /sabu/config/update.sh" >> crontab -e

# Install other package
apt install parted ntfs-3g yara clamav exiftool ipcalc iptables -y
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

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The installation script has been executed successfully" >> /sabu/logs/sabu.log

# Reboot
reboot

# --- Script By SABU --- #
