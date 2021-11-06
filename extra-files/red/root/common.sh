#!/bin/sh

msg() {
	echo "[$(date)] $1" > /var/log/messages
}
