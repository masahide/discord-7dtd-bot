#!/bin/bash

cron=/etc/cron.d/7dtd_shutdown
cron_backup=/root/7dtd_shutdown.cron
set -x
[[ -f $cron_backup ]] && mv $cron_backup $cron

# start
systemctl start 7dtd

