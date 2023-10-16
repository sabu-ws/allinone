#!/bin/bash

# RETRIEVE NETWORK INFORMATION
interface=$(jq '.network | .interface' /sabu/config/config.json  | tr -d '"')
address=$(jq '.network | .ip' /sabu/config/config.json  | tr -d '"')
netmask=$(jq '.network | .netmask' /sabu/config/config.json  | tr -d '"')
gateway=$(jq '.network | .gateway' /sabu/config/config.json  | tr -d '"')
nameserver1=$(jq '.network | .dns1' /sabu/config/config.json  | tr -d '"')
nameserver2=$(jq '.network | .dns2' /sabu/config/config.json  | tr -d '"')

# Check if dhcp or static interface
check_dhcp=$(grep $interface /etc/network/interfaces | tail -n +2 | cut -d ':' -f1 | awk {'print $4'})

# Check ligne number "nameserver"
nameserver_count=0
while IFS= read -r line; do
  if [[ $line == "nameserver"* ]]; then
    ((nameserver_count++))
  fi
done < /etc/resolv.conf

# INTERFACE
if [[ $check_dhcp == "dhcp" ]]
then
    sudo sed -i "s/allow-hotplug $interface/auto $interface/" /etc/network/interfaces
    sudo sed -i "s/dhcp/static/" /etc/network/interfaces
    sudo sed -i "/iface $interface inet static/a\address $address\nnetmask $netmask\ngateway $gateway" /etc/network/interfaces
else
    # Retrieve the line number of the network interface
    lignes=$(grep -n $interface /etc/network/interfaces | tail -n +2 | cut -d ':' -f1)

    # Change the network information in relation to the arguments
    sudo sed -i "$(($lignes+1))c\address $address" /etc/network/interfaces
    sudo sed -i "$(($lignes+2))c\netmask $netmask" /etc/network/interfaces
    sudo sed -i "$(($lignes+3))c\gateway $gateway" /etc/network/interfaces
fi

# NAMESERVER
if [[ $nameserver_count == 1 ]]
then   
    sudo sed -i "1c\nameserver $nameserver1" /etc/resolv.conf
    echo "nameserver $nameserver2" | sudo tee -a - /etc/resolv.conf

else
    sudo sed -i "1c\nameserver $nameserver1" /etc/resolv.conf
    sudo sed -i "2c\nameserver $nameserver2" /etc/resolv.conf
fi

# Restart the network configuration
sudo systemctl restart networking.service

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [NETWORK][Interface] The setup network interface $interface has been configured" >> /sabu/logs/network.log

# --- Script By SABU --- #