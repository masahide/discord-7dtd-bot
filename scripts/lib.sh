#!/bin/bash

PARAMFILE=~/.params_cache
get_params () {
	find $PARAMFILE -mmin 5 -exec rm -rf {} \;
	[[ ! -s $PARAMFILE ]] && rm -f $PARAMFILE
	[[ -f $PARAMFILE ]] && cat $PARAMFILE && return
	aws ssm get-parameters-by-path \
		--path ${PARAM_PATH} \
		--with-decryption \
		| tee $PARAMFILE
}

get_param () {
	jq -r '.Parameters[]|select(.Name |endswith("'$1'"))|.Value'
}

PARAMS=$(get_params)
DISCORD_CHANNEL_ID=$(echo $PARAMS|get_param channel_id)
TOKEN=$(echo $PARAMS|get_param bot_token)
DOMAIN_NAME=$(echo $PARAMS|get_param dmain_name)
HOST_ZONE_ID=$(echo $PARAMS|get_param host_zone_id) 
PASS=$(echo $PARAMS|get_param pass) 



post_discord () {
	json=/tmp/7dtd_executer.data.json
	[[ -f $json ]] && [[ $(date "+%s") -le $(jq -r '.["ttl"]' $json) ]] && URL=$(jq -r '.["url"]' $json)
	[[ -z $URL ]] && URL=https://discordapp.com/api/channels/${DISCORD_CHANNEL_ID}/messages 

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
	${URL} \
	-d @- 
}

upsert_domain () {
	IPADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
	RECORD='{
    "Comment": "UPSERT '${DOMAIN_NAME}'",
    "Changes": [{
    "Action": "UPSERT",
	"ResourceRecordSet": {
	    "Name": "'${DOMAIN_NAME}'",
	    "Type": "A",
	    "TTL": 5,
	    "ResourceRecords": [{ "Value": "'${IPADDRESS}'"}]
}}]}'
	aws route53 change-resource-record-sets \
		--hosted-zone-id ${HOST_ZONE_ID} \
		--change-batch \
		file://<(echo ${RECORD})
}


post_discord2 () {
	json=/tmp/7dtd_executer.data.json
	[[ -f $json ]] && [[ $(date "+%s") -le $(jq -r '.["ttl"]' $json) ]] && URL=$(jq -r '.["url"]' $json)
	[[ -z $URL ]] && URL=https://discordapp.com/api/channels/${DISCORD_CHANNEL_ID}/messages 

	echo '{
  "content": "'${CONTENT}'",
  "tts": false
}' \
	|curl -X POST -H "Content-Type: application/json" \
	-H "Authorization: Bot ${TOKEN}" \
	${URL} \
	-d @- 
}
