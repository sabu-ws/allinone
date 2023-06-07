#!/bin/bash

# CHECK OS
os=$(lsb_release -i | awk '{print $3}')
version=$(lsb_release -r | grep "Release" | awk '{print $2}')
if [[ $os != "Debian" || ($version != "11" && $version != "12") ]]
then
  clear
  echo "========================   [  SABU  ]   ========================"
  echo "------------   ERROR, please use Debian 11 or 12   -------------"
  echo "================================================================"
  exit 1
fi

# RETRIEVE NETWORK IP
ipaddress=$(ip -br a | tail -n 1 | awk '{print $3}' | cut -d '/' -f 1)

# START WHIPTAIL PROGRESS
{

# Disable IPV6
cp sysctl/70-disable-ipv6.conf /etc/sysctl.d/70-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf
echo '10' && sleep 1 # Progress

# Setup workspace
mkdir /sabu
cp -r * /sabu
echo '20' && sleep 1 # Progress

# Install packages 
apt install sudo python3 python3-pip jq -y > /dev/null
echo '50' && sleep 3 # Progress

# Adduser/permission SABU
adduser --disabled-password --shell=/bin/false --no-create-home --gecos "" sabu
echo "sabu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chown -R sabu:sabu /sabu
chmod -R +x /sabu/scripts
chmod -R +x /sabu/config
echo '60' && sleep 2 # Progress

# Install python requirements
if [ $version == "11" ]
then
  pip3 install -r ./gui/requirements.txt
elif [ $version == "12" ]
then
  pip3 install -r ./gui/requirements.txt --break-system-packages
fi
echo '80' && sleep 3 # Progress

# Start GUI
mv ./service/sabu.service /etc/systemd/system/
rm -r /sabu/service
systemctl daemon-reload > /dev/null
systemctl start sabu.service
systemctl enable sabu.service
echo '95' && sleep 2 # Progress

# Remove tmp folder
rm -rf ../SABU
echo '100' # Progress

# Log Action
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The setup script has been executed successfully" >> /sabu/logs/sabu.log

sleep 3 # Progress

} | whiptail --title "SABU" --gauge "Installation in progress, please wait..." 8 70 0

# DISPLAY END
whiptail --title "SABU" --msgbox 'Setup completed !\nOpen browser and visit : http://'$ipaddress:8888/'' 8 70 0

# --- Script By SABU --- #
