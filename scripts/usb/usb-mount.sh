#!/bin/bash

# UNMOUNT OLD USB STICK
sudo umount /mnt/usb

# CHECK USB STICK IS PARTITIONNED
partitioned=1

while read x
do
	if [[ "$x" =~ ^sd[a-z][0-9] ]]; 
	then
		partitioned="0"
	fi;
done << EOF

$(ls /dev)
EOF

# MOUNT USB STICK AND PARTITIONS
if [ "$partitioned" = "0" ]; 
then
	sudo mount /dev/sd[a-z][0-9] /mnt/usb
else
	sudo mount /dev/sd[a-z] /mnt/usb
fi;

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [USB][Mount] USB key mounted in '/mnt/usb'" >> /sabu/logs/usb.log

# --- Script By SABU --- #
