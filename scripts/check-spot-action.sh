#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

check_action () {
	TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" v http://169.254.169.254/latest/meta-data/spot/instance-action|grep action
}


start_shutdown () {
	CONTENT="spot action: stop"
	TITLE="サーバーを停止します"
	DESCRIPTION="amazonからスポットインスタンス中断通知を受信しました\n一旦サーバーを安全に停止します\n再度起動させれば復活する可能性はあります\nスポットインスタンスの中断について:https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/spot-interruptions.html"
	post_discord
	sleep 30
	${SCRIPT_DIR}/shutdown.sh
	/usr/sbin/shutdown -h now
	exit
}

for i in {1..5}
do	
	check_action && start_shutdown
	sleep 10
done
