#!/bin/bash

cron=/etc/cron.d/7dtd_shutdown
set -x
[[ -f $cron ]] && mv $cron /root/7dtd_shutdown.cron
psdowncron=$(ps axuw|grep down_cro[n]|awk '{print $2}')
[[ -n $psdowncron ]] && kill $psdowncron


# stop
systemctl stop 7dtd
sleep 3

# stopできなかったときのために
ps7dtd=$(ps axuw|grep 7Da[y]|awk '{print $2}')
[[ -n $ps7dtd ]] && kill $ps7dtd
