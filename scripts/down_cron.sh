#!/bin/bash

TIME=600

SCRIPT_DIR=$(cd $(dirname $0); pwd)

FILE=/tmp/players

players () {
    ${SCRIPT_DIR}/listplayer.sh > $FILE
    cat $FILE|grep "in the game"| grep -Eo "[0-9]{1,4}"
}

systemctl status 7dtd|grep -q "Active: inactive" && exit
[[ "$(players)" -eq "0" ]]  || exit 0

echo sleep $TIME sec...
sleep $TIME

systemctl status 7dtd|grep -q "Active: inactive" && exit
[[ "$(players)" -eq "0" ]]  || exit 0

${SCRIPT_DIR}/shutdown.sh
/opt/games/discord-7dtd-bot/scripts/backup.sh backup
/usr/sbin/shutdown -h now
