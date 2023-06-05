#!/bin/bash

# Disable IPV6
cp sysctl/70-disable-ipv6.conf /etc/sysctl.d/70-disable-ipv6.conf
sudo sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf

# RETRIEVE NETWORK IP
ipaddress=$(ip -br a | tail -n 1 | awk '{print $3}' | cut -d '/' -f 1)

# Setup workspace
sudo mkdir /sabu
sudo cp -r * /sabu

# Install packages 
sudo apt install sudo python3 python3-pip jq debconf-utils -y

sleep 3

# Adduser/permission SABU
sudo adduser sabu --shell=/bin/false --no-create-home
echo "sabu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo chown -R sabu:sabu /sabu
sudo chmod -R +x /sabu/scripts
sudo chmod -R +x /sabu/config

# Install python requirements
sudo pip3 install -r ./gui/requirements.txt --break-system-packages

sleep 3

# Start gui
sudo mv ./service/sabu.service /etc/systemd/system/
sudo rm -r /sabu/service
sudo systemctl daemon-reload
sudo systemctl start sabu.service
sudo systemctl enable sabu.service

# End
echo "=====================   [  SABU  ]   ====================="
echo "-----------------   Setup completed !   ------------------"
echo "   Open browser and visit : http://$ipaddress:8888/    "
echo "=========================================================="

# Remove tmp folder
sudo rm -rf ../SABU

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The setup script has been executed successfully" >> /sabu/logs/sabu.log

# --- Script By SABU --- #
