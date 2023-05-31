 #!/bin/bash
 
# Log started device
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] Your device has been started" >> /sabu/logs/sabu.log

# Check if sabu.service is running
status=$(systemctl status sabu.service | grep Active | awk '{ print $3}' | tr -d '()')

if [ $status="running" ]
then
  echo "[SABU] The sabu service has running" >> /sabu/logs/sabu.log
else
  echo "[SABU] The sabu service has down" >> /sabu/logs/sabu.log
fi

# --- Script By SABU --- #
