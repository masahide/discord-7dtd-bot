
# install

```bash
sudo su -
mkdir -p /opt/games
cd /opt/games
git cline git@github.com:masahide/discord-7dtd-bot.git
cd discord-7dtd-bot/scripts

# cp systemd  service file
cp 7dtd.service  /etc/systemd/system/7dtd.service
systemctl daemon-reload

```

## root crontab
```
0,15,30,45 * * * * /opt/games/discord-7dtd-bot/scripts/down_cron.sh
```

