#!/usr/bin/expect
set timeout 600
spawn telnet localhost 8081
expect -re "GameServer.LogOn successful"
send "exit\r"

expect eof
