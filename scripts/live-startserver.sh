#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)

SERVERDIR=/opt/games/7days
#SERVERDIR=`dirname "$0"`
cd "$SERVERDIR"

PARAMS=$@

CONFIGFILE=
while test $# -gt 0
do
	if [ `echo $1 | cut -c 1-12` = "-configfile=" ]; then
		CONFIGFILE=`echo $1 | cut -c 13-`
	fi
	shift
done

if [ "$CONFIGFILE" = "" ]; then
	echo "No config file specified. Call this script like this:"
	echo "  ./startserver.sh -configfile=serverconfig.xml"
	exit 1
else
	if [ -f "$CONFIGFILE" ]; then
		echo Using config file: $CONFIGFILE
	else
		echo "Specified config file $CONFIGFILE does not exist."
		exit 1
	fi
fi

export LD_LIBRARY_PATH=.
#export MALLOC_CHECK_=0

$SCRIPT_DIR/send_start.sh &
$SCRIPT_DIR/update_allow_list.sh &
$SCRIPT_DIR/check-spot-action.sh &

./7DaysToDieServer.x86_64 -logfile /home/7dtd/server.log -quit -batchmode -nographics -dedicated $PARAMS
