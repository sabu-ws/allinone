#!/bin/bash

# RETRIEVE NETWORK IP
ipaddress=$(ip -br a | tail -n 1 | awk '{print $3}' | cut -d '/' -f 1)

# Update packages
apt update
apt upgrade -y

# Add user SABU

# Make permissions : user sabu

# install package 

# start gui

# end
echo "Setup completed !"
echo "Open browser and visit : https://$ipaddress/admin
