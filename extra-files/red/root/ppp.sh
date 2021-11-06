#!/bin/sh

# use local_ip:remote_ip (see man pppd)

source /root/common.sh

msg "starting ppp as a daemon, persist up"

pppd persist noauth nocrtscts local defaultroute 169.254.1.2:169.254.1.1 /dev/ttyS1 115200

