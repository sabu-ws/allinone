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
cp sysctl/70-disable-ipv6.conf /etc/sysctl.d/70-disable-ipv6.conf > /dev/null 2>&1
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf > /dev/null 2>&1
echo '10' && sleep 1 # Progress

# Setup workspace
mkdir /sabu > /dev/null 2>&1
cp -r * /sabu > /dev/null 2>&1
echo '20' && sleep 1 # Progress

# Setup reverse proxy
apt install nginx -y > /dev/null 2>&1
rm /etc/nginx/sites-available/default 1>/dev/null 2>&1
rm /etc/nginx/sites-enabled/default 1>/dev/null 2>&1
cp /sabu/nginx/sabu-front.conf /etc/nginx/sites-available/sabu-front.conf > /dev/null 2>&1
ln -s /etc/nginx/sites-available/sabu-front.conf /etc/nginx/sites-enabled/sabu-front.conf > /dev/null 2>&1
systemctl enable nginx > /dev/null 2>&1
systemctl restart nginx > /dev/null 2>&1
echo '35' && sleep 2 # Progress

# Install packages 
apt install sudo python3 python3-pip jq -y > /dev/null 2>&1
echo '50' && sleep 3 # Progress

# Adduser/permission SABU
adduser --disabled-password --shell=/bin/false --no-create-home --gecos "" sabu > /dev/null 2>&1
echo "sabu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chown -R sabu:sabu /sabu > /dev/null 2>&1
chmod -R +x /sabu/scripts > /dev/null 2>&1
chmod -R +x /sabu/config > /dev/null 2>&1
echo '60' && sleep 2 # Progress

# Install python requirements
if [ $version == "11" ]
then
  pip3 install -r ./gui/requirements.txt > /dev/null 2>&1
elif [ $version == "12" ]
then
  pip3 install -r ./gui/requirements.txt --break-system-packages > /dev/null 2>&1
fi
echo '80' && sleep 3 # Progress

# Start GUI
mv ./service/sabu.service /etc/systemd/system/ > /dev/null 2>&1
mv ./service/sabu-ux.service /etc/systemd/system/ > /dev/null 2>&1
systemctl daemon-reload > /dev/null 2>&1
systemctl start sabu.service > /dev/null 2>&1
systemctl start sabu-ux.service > /dev/null 2>&1
systemctl enable sabu.service > /dev/null 2>&1
systemctl enable sabu-ux.service > /dev/null 2>&1
echo '95' && sleep 2 # Progress

# Remove tmp folder
rm -rf ../SABU > /dev/null 2>&1
echo '100' # Progress

# Log Action
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The setup script has been executed successfully" >> /sabu/logs/sabu.log

sleep 3 # Progress

} | whiptail --title "SABU" --gauge "Installation in progress, please wait..." 8 70 0

# DISPLAY END
whiptail --title "SABU" --msgbox 'Setup completed !\nOpen browser and visit : https://'$ipaddress/'' 8 70 0

# --- Script By SABU --- #
