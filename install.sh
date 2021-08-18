#!/bin/sh

msg() {
	echo -e "\x1b[1;33m${1}\x1b[0m"
}

if [ $# == 0 ]; then
	echo "usage: install.sh DEVICE"
	exit 1
fi

msg "mounting card ..."

mountpoint=/media/sdcard
device=$1

if [ ! -e ${mountpoint} ]; then
	echo "creating mountpoint $mountpoint"
	mkdir -p ${mountpoint}
fi

sudo mount ${device} ${mountpoint}
msg "mounting card OK"

msg "clearing card rootfs ..."
sudo rm -r ${mountpoint}/*
msg "clearing card rootfs OK"
msg "copying files ..."
sudo cp -a targetfs/* ${mountpoint}
sudo chown -R root:root ${mountpoint}
sudo umount ${mountpoint}
sync; sync
msg "copying files OK"

