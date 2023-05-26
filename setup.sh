#!/bin/bash

# RETRIEVE NETWORK IP
ipaddress=$(ip -br a | tail -n 1 | awk '{print $3}' | cut -d '/' -f 1)

# Setup workspace
mkdir /sabu
cp -r * /sabu

# Install packages 
apt install sudo python3 python3-pip ipcalc iptables iptables-persistent -y

sleep 3

# Adduser/permission SABU
adduser sabu --shell=/bin/false --no-create-home
echo "sabu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chown sabu:sabu /sabu
chmod +x -R /sabu/scripts

# Install python requirements
pip3 install -r ./gui/requirements.txt

sleep 3

# Start gui
systemctl start sabu.service

# End
echo "Setup completed !"
echo "Open browser and visit : https://$ipaddress/admin"

# Remove tmp folder
rm -rf ../SABU