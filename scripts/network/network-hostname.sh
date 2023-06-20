#!/bin/bash

# Change hosts in /etc/hosts
get_hostname=$(hostname)
sudo sed -i "s/127\.0\.1\.1\t\w*$/127\.0\.1\.1\t${get_hostname}/g" /etc/hosts