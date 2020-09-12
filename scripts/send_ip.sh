#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh




upsert_domain

IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
CONTENT="${DOMAIN_NAME} のIPは ${IPADDRESS} になりました"
TITLE="${DOMAIN_NAME} (${IPADDRESS})"
DESCRIPTION="7days to dieの起動処理を始めました. しばらくお待ちください."
post_discord

