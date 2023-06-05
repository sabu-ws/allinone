#!/bin/bash

# Absolute path to scripts
SCRIPT_CHECK="/sabu/config/check.sh"
SCRIPT_UPDATE="/sabu/config/update.sh"

# Target user
USER="sabu"

# Extract content from user crontab
crontab -u "$USER" -l > /tmp/crontab_tmp

# Add new cron job to crontab content
echo "@reboot sh $SCRIPT_CHECK" > /tmp/crontab_tmp
echo "0 2 * * * sh $SCRIPT_UPDATE" >> /tmp/crontab_tmp

# Update user crontab with changed content
crontab -u "$USER" /tmp/crontab_tmp

# Delete temporary file
rm /tmp/crontab_tmp

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The cron have been added" >> /sabu/logs/sabu.log

# --- Script By SABU --- #
