#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh




upsert_domain

IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
CONTENT="serverが起動しました"
TITLE="${DOMAIN_NAME} (${IPADDRESS})"
DESCRIPTION="Pass: ${PASS}"
post_discord

