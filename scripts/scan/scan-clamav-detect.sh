#!/bin/bash

TIMESTAMP=$(date +%s)
DATE=$(date +"[%Y-%m-%d %H:%M:%S]")
SCAN_PATH="/mnt/usb/"
LOG_PATH="/sabu/logs/scan/clamav"

# CLAMSCAN
clamscan -r $SCAN_PATH > "$LOG_PATH/clamscan-detect-$DATE.log"

# LOG ACTION
echo "$DATE [SCAN][Clamav] New scan available clamscan-detect-$TIMESTAMP.log" >> $LOG_PATH/../../scan.log
echo "clamscan-detect-$DATE.log" > $LOG_PATH/last-scan.log

# --- Script By SABU --- #
