#!/bin/bash

path=$(pwd)

# UNMOUNT USB STICK
sudo umount /mnt/usb

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [USB][Umount] USB key unmounted" >> $path/../../logs/usb.log

# --- Script By SABU --- #
