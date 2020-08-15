#!/bin/bash

[[ $1 == "" ]] && sleep 60

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh


${SCRIPT_DIR}/check_start.sh > /tmp/check_start.log

IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

CONTENT="GameServer.LogOn successful"
TITLE="${DOMAIN_NAME}"
DESCRIPTION="Pass: ${PASS}"
post_discord


