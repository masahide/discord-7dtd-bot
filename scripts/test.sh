#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh




IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
CONTENT="${DOMAIN_NAME} のIPは ${IPADDRESS} になりました"
TITLE="${DOMAIN_NAME} (${IPADDRESS})"
DESCRIPTION="7days to dieの起動処理を始めました. しばらくお待ちください."


echo "PARAM_PATH=$PARAM_PATH"
echo "IPADDRESS = [$IPADDRESS]"
echo "CONTENT = [$CONTENT]"
echo "DOMAIN_NAME = [$DOMAIN_NAME]"
# echo "PARAMS= $PARAMS"
echo "DISCORD_CHANNEL_ID=$DISCORD_CHANNEL_ID"
echo "TOKEN=$TOKEN"
echo "HOST_ZONE_ID=$HOST_ZONE_ID"
echo "PASS=$PASS"

set -ex
#aws ssm get-parameters-by-path \
#	--path ${PARAM_PATH} \
#	--with-decryption \



FILE=/tmp/players.tmp
players () {
    ${SCRIPT_DIR}/listplayer.sh > $FILE
    cat $FILE|grep "in the game"| grep -Eo "[0-9]{1,4}"
}
PLAYERS=$(players)
echo "players=$PLAYERS"


