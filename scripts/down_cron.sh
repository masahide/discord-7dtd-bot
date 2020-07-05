TIME=600

SCRIPT_DIR=$(cd $(dirname $0); pwd)

FILE=/tmp/players

players () {
    ${SCRIPT_DIR}/listplayer.sh > $FILE
    cat $FILE|grep "in the game"| grep -Eo "[0-9]{1,4}"
}

[ "$(players)" -eq "0" ]  || exit 0

echo sleep $TIME sec...
sleep $TIME

[ "$(players)" -eq "0" ]  || exit 0

${SCRIPT_DIR}/shutdown.sh
/usr/sbin/shutdown -h now
