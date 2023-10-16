#!/bin/bash

# Change hosts in /etc/hosts
get_hostname=$(hostname)
sudo sed -i "s/$1/$get_hostname/g" /etc/hosts

# --- Script By SABU --- #
