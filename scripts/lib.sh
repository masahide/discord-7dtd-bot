#!/bin/bash

TOKEN=$(aws ssm get-parameters --names ${PARAM_PATH} --with-decryption|jq -r '.[][]["Value"]')

print_args (){
	echo 1:$1
	echo 2:$2
	echo 3:$3
	echo 4:$4
	echo 5:$5
	echo 6:$6
	echo 7:$7
	echo 8:$8
	echo 9:$9
}

send_discord () {
	curl --verbose -s -X POST -H "Content-Type: application/json" \
	  -H "Authorization: Bot ${TOKEN}" \
	  https://discordapp.com/api/channels/${DISCORD_CHANNEL_ID}/messages \
	  -d '{
	  "content": "'${CONTENT}'",
	  "tts": false,
	  "embed": {
	    "title": "'${TITLE}'",
	    "description": "'${DESCRIPTION}'"
	  }
	}'
}
 

post_discord () {
	echo '{
  "content": "'${CONTENT}'",
  "tts": false,
  "embed": {
    "title": "'${TITLE}'",
    "description": "'${DESCRIPTION}'"
  }
}' \
	|curl -X POST -H "Content-Type: application/json" \
	-H "Authorization: Bot ${TOKEN}" \
	https://discordapp.com/api/channels/${DISCORD_CHANNEL_ID}/messages \
	-d @- 
	
}

