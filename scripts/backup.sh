#!/bin/bash

#set -ex
hostname=$(hostname)
date=$(/bin/date +"%Y%m%d_%H%M")
s3path="s3://backup-suzume/backup/${hostname}_${date}.gz"
tmppath="/tmp/${hostname}_${date}.gz"

echo "7dtd backup started." | logger -t 7dtd_backup
[[ -z $1 ]] && /opt/games/discord-7dtd-bot/scripts/world_save.sh
tar -C /home/7dtd/ -zcf - .local | aws s3 cp - "${s3path}"  
echo "7dtd backup finished." | logger -t x 7dtd_backup

