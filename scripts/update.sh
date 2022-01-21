#!/bin/bash
mv /etc/cron.d/7dtd_shutdown /root/7dtd_shutdown.cron

# stop server
systemctl stop 7dtd

set -ex
sleep 3

# delete old version
rm -rf /opt/games/steamcmd/ /opt/games/7days
mkdir /opt/games/steamcmd/
cd /opt/games/steamcmd/

# install steam cmd
wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd_linux.tar.gz && rm -f steamcmd_linux.tar.gz

# install 7days to die
/opt/games/steamcmd/steamcmd.sh \
	+login anonymous \
	+force_install_dir /opt/games/7days \
	+app_update 294420 \
        -beta latest_experimental \
	+quit
chown 7dtd: -R /opt/games/7days

sleep 3

# start server
##systemctl start 7dtd
mv /root/7dtd_shutdown.cron /etc/cron.d/7dtd_shutdown 
