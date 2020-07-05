#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh


IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

CONTENT="サーバーIPアドレス"
TITLE="${IPADDRESS}"
DESCRIPTION=""
post_discord

