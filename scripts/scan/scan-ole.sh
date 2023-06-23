#!/bin/bash

pathUSB='/mnt/usb'
LOG_PATH='/sabu/logs/scan/ole'
DATESTART=$(date +%s)
DATE=$(date +"[%Y-%m-%d %H:%M:%S]")

touch $LOG_PATH/ole-$DATESTART.log

for i in $(find $pathUSB -type f)
do
        format=$(oleid $i | grep "Container format" | cut -d'|' -f2 | tr -d ' ')
        if [ "$format" = "OLE" ];
        then
                macro=$(oleid $i | grep -E "VBA Macros|XML Macros" | cut -d'|' -f2 | tr -d ' ')
                if [ "$macro" = "Yes,suspicious" ];
                then
                        echo "$i is suspicious" >> $LOG_PATH/ole-$DATESTART.log
                fi;
        fi;
done

# LOG ACTION
echo "$DATE [SCAN][OLE] New scan available ole-$DATESTART.log" >> $LOG_PATH/../../scan.log
echo "ole-$DATESTART.log" > $LOG_PATH/last-scan.log

# --- Script By SABU --- #
