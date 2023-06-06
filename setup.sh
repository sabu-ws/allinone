#!/bin/bash

# Disable IPV6
cp sysctl/70-disable-ipv6.conf /etc/sysctl.d/70-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf

# RETRIEVE NETWORK IP
ipaddress=$(ip -br a | tail -n 1 | awk '{print $3}' | cut -d '/' -f 1)

# Setup workspace
mkdir /sabu
cp -r * /sabu

# Install packages 
apt install sudo python3 python3-pip jq -y

sleep 3

# Adduser/permission SABU
adduser --disabled-password --shell=/bin/false --no-create-home --gecos "" sabu
echo "sabu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chown -R sabu:sabu /sabu
chmod -R +x /sabu/scripts
chmod -R +x /sabu/config

# Install python requirements
pip3 install -r ./gui/requirements.txt --break-system-packages

sleep 3

# Start gui
mv ./service/sabu.service /etc/systemd/system/
rm -r /sabu/service
systemctl daemon-reload
systemctl start sabu.service
systemctl enable sabu.service

# End
echo "=====================   [  SABU  ]   ====================="
echo "-----------------   Setup completed !   ------------------"
echo "   Open browser and visit : http://$ipaddress:8888/    "
echo "=========================================================="

# Remove tmp folder
rm -rf ../SABU

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The setup script has been executed successfully" >> /sabu/logs/sabu.log

# --- Script By SABU --- #
