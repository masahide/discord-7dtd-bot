
SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/setting.sh
. ${SCRIPT_DIR}/lib.sh

systemctl stop 7dtdexecuter.service
sleep 2
aws dynamodb put-item \
    --table-name $TABLENAME \
    --item '{
        "id": {"S": "'$INSTANCEID'" },
        "ttl": {"N": "0" } ,
        "state": {"S": "stopped"}
      }' \
      2>&1 |logger -t dynamodb-put-item
