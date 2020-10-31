#!/bin/bash

LISTFILE=/etc/ipset_list
MIN=1440
SETNAME=allow_list

find $LISTFILE -mmin +$MIN -a -type f -exec rm -f {} \;
[[ -f $LISTFILE ]] || \
	curl -sL http://nami.jp/ipv4bycc/cidr.txt.gz \
	|zcat \
	|sed -n 's/^JP\t//p' \
	>$LISTFILE
ipset create $SETNAME hash:net
ipset flush $SETNAME

while read line
do
	ipset add $SETNAME $line
done < $LISTFILE

/sbin/iptables --flush
/sbin/iptables -A INPUT -p ALL -s 127.0.0.1 -j ACCEPT
/sbin/iptables -A INPUT -p ALL -m state --state ESTABLISHED,RELATED -j ACCEPT
# UDP（26900-26903)必須
/sbin/iptables -A INPUT -p udp --dport 26900:26903 -m set --match-set $SETNAME src -j ACCEPT
/sbin/iptables -A INPUT -p udp --dport 26900:26903 -j DROP
# TCP（26900）必須
/sbin/iptables -A INPUT -p tcp --dport 26900 -m set --match-set $SETNAME src -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 26900 -j DROP
# https
/sbin/iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -m set --match-set $SETNAME src -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 443 -j DROP
# api port
/sbin/iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 28082 -m set --match-set $SETNAME src -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 28082 -j DROP

