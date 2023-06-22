#!/bin/bash

# Absolute path to scripts
SCRIPT_LAUNCH_UPDATE="/sabu/config/launch_update.sh"

# Target user
USER="sabu"

# Extract content from user crontab
crontab -u "$USER" -l > /tmp/crontab_tmp

# Add new cron job to crontab content
echo "@reboot sh $SCRIPT_LAUNCH_UPDATE" >> /tmp/crontab_tmp

# Update user crontab with changed content
crontab -u "$USER" /tmp/crontab_tmp

# Delete temporary file
rm /tmp/crontab_tmp

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The before update script was set" >> /sabu/logs/sabu.log

sudo reboot

# --- Script By SABU --- #
