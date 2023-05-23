#!/bin/bash

# UNMOUNT USB STICK
sudo umount /mnt/usb

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date USB Unmount" >> /sabu/usb.log
