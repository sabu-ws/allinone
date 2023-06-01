#!/bin/bash

pathUSB='/mnt/usb'
LOG_PATH='/sabu/logs/'
outfile=$(date +%s)

for i in $(find $pathUSB -type f)
do
        format=$(oleid $i | grep "Container format" | cut -d'|' -f2 | tr -d ' ')
        if [ "$format" = "OLE" ];
        then
                macro=$(oleid $i | grep -E "VBA Macros|XML Macros" | cut -d'|' -f2 | tr -d ' ')
                if [ "$macro" = "Yes,suspicious" ];
                then
                        echo "$i is suspicious" >> $LOG_PATH/ole-$DATE.log
                fi;
        fi;
done
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [Scan][OLE] New scan available ole-$DATE.log" >> $LOG_PATH/scan.log
echo "ole-$DATE.log"

# --- Script By SABU --- #
