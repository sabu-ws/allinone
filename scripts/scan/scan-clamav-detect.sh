#!/bin/bash

DATE=$(date +%s)
SCAN_PATH="/mnt/usb/"
LOG_PATH="/sabu/logs/scan/clamav"

# CLAMSCAN
clamscan -r $SCAN_PATH > "$LOG_PATH/clamscan-detect-$DATE.log"

date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SCAN][Clamav] New scan available clamscan-detect-$DATE.log" >> $LOG_PATH/../../scan.log
echo "clamscan-detect-$DATE.log" > $LOG_PATH/last-scan.log

# --- Script By SABU --- #
