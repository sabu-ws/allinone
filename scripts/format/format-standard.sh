#!/bin/bash

# Identifier of the USB key
device='/dev/sd[a-z]'

# Delete all partitions on the USB key
echo 'yes' | sudo parted -s $device mklabel msdos

# Create a new primary partition occupying all available space
echo 'yes' | sudo parted -s -a optimal $device mkpart primary ntfs 0% 100%

# Update partition table
sudo partprobe $device

# Wait for changes to take effect
sleep 2
sudo sh /sabu/scripts/usb/usb-unmount.sh

# Format partition to NTFS
sudo mkfs.ntfs -f ${device}1

# Mount partition
sleep 2
sudo bash /sabu/scripts/usb/usb-mount.sh

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [FORMAT][Standard] USB key formatted in NTFS" >> /sabu/logs/format.log

# --- Script By SABU --- #

