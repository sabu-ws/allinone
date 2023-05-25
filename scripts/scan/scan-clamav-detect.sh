#!/bin/bash

DATE=$(/bin/date "+%d%m%Y%H%M%S")
PATH="/mnt/usb/"
LOG_PATH="/sabu/logs/clamav"

/usr/bin/echo $LOG_NAME

# CLAMSCAN
#/usr/bin/echo "$LOG_PATH/clamscan-detect-$DATE.log"
#/usr/bin/clamscan -r $PATH > "$LOG_PATH/clamscan-detect-$DATE.log"

#/usr/bin/cat "$LOG_PATH/clamscan-detect-$DATE.log"
DETECT_FILE=$(/usr/bin/cat "$LOG_PATH/clamscan-detect-25052023095241.log" | /usr/bin/grep FOUND | /usr/bin/tr -d ':' | /usr/bin/cut -d' ' -f 1,2)


echo "--- SCAN REPORT ---"
echo "Date: $(/bin/date "+%d/%m/%Y %H:%M:%S")"
echo "Infected files: $(/usr/bin/cat "/sabu/logs/clamav/clamscan-detect-25052023095241.log" | /usr/bin/grep "Infected files" | /usr/bin/cut -d' ' -f3)"
echo "Files:"
echo "$(/usr/bin/cat "$LOG_PATH/clamscan-detect-25052023095241.log" | /usr/bin/grep FOUND | /usr/bin/tr -d ':' | /usr/bin/cut -d' ' -f 1,2)"
