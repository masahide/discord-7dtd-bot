#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

check_action () {
	TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" v http://169.254.169.254/latest/meta-data/spot/instance-action|grep action
}


start_shutdown () {
	CONTENT="spot action: stop"
	TITLE="サーバーを停止します"
	DESCRIPTION="amazonからスポットインスタンス中断通知を受信しました\n一旦サーバーを安全に停止します\n停止後にDiscordから再起動してください"
	post_discord
	sleep 30
	${SCRIPT_DIR}/shutdown.sh
	/usr/sbin/shutdown -h now
	exit
}

for i in {1..5}
do	
	check_action && ${SCRIPT_DIR}/backup.sh backup && start_shutdown
	sleep 10
done
