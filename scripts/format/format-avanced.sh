#!/bin/bash

# Identifier of the USB key
device='/dev/sd[a-z]'

# Delete all partitions on the USB key
echo 'yes' | parted -s $device mklabel msdos

# Write zeros to USB key
dd if=/dev/zero of="$device" bs=4M status=progress

# Create a new primary partition occupying all available space
echo 'yes' | parted -s -a optimal $device mkpart primary ntfs 0% 100%

# Update partition table
partprobe $device

# Wait for changes to take effect
sleep 1

# Format partition to NTFS
mkfs.ntfs -f ${device}1

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [FORMAT][Avanced] USB key formatted in NTFS with zeroes" >> /sabu/logs/format.log

# --- Script By SABU --- #
