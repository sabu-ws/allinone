#!/bin/bash

# Create new partition
echo "n
p
1
"

# Change the partition to NTFS
echo "t
1
7
"

# Save changes and exit
echo "w
" | fdisk /dev/sd[a-z]

# Format partition to NTFS (use package mkntfs)
mkntfs -Q /dev/sd[a-z]1

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [FORMAT][Standard] USB key formatted in NTFS" >> /sabu/logs/format.log

# --- Script By SABU --- #
