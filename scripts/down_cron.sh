#!/bin/bash

TIME=600

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh

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
${SCRIPT_DIR}/backup.sh backup
${SCRIPT_DIR}/dynaup.sh
CONTENT="サーバーを停止しました"
post_discord2
/usr/sbin/shutdown -h now
