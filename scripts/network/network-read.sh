#!/bin/bash

#     Script By SABU     #
# Last edit : 27/01/2023 #

# Retrieve network informations
address=$(grep address /etc/network/interfaces | cut -d ' ' -f2)
netmask=$(grep netmask /etc/network/interfaces | cut -d ' ' -f2)
gateway=$(grep gateway /etc/network/interfaces | cut -d ' ' -f2)
nameserver=$(grep nameserver /etc/resolv.conf | cut -d ' ' -f2)

# Display informations
echo -e "$address\n$netmask\n$gateway\n$nameserver"
