#!/bin/bash

DATE=$(date "+%d%m%Y%H%M%S")
SCAN_PATH="/mnt/usb/"
LOG_PATH="/sabu/logs/clamav"

# CLAMSCAN
clamscan -r $SCAN_PATH > "$LOG_PATH/clamscan-detect-$DATE.log"

date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [Scan][Clamav] New scan available clamscan-detect-$DATE.log" >> $LOG_PATH/../scan.log
