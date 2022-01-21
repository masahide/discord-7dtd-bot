#!/bin/bash

[[ $1 == "" ]] && sleep 60

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh


${SCRIPT_DIR}/check_start.sh > /tmp/check_start.log

IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

CONTENT="${DOMAIN_NAME} 起動完了\nサーバーの起動が完了しました。ゲームが始められます。\nURL: steam://connect/${DOMAIN_NAME}:26900\nPass: ${PASS}"
TITLE=""
DESCRIPTION=""
post_discord2


