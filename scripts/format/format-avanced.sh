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

# Format partition to NTFS (use package mkntfs) // Force : With zeroes
mkntfs -F /dev/sd[a-z]1

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [FORMAT][Avanced] USB key formatted in NTFS with zeroes" >> /sabu/logs/format.log

# --- Script By SABU --- #
