#!/bin/sh

if [ $# == 0 ]; then
	echo "usage: install.sh DEVICE"
	exit 1
fi

mountpoint=/media/sdcard
device=$1

if [ ! -e ${mountpoint} ]; then
	echo "creating mountpoint $mountpoint"
	mkdir -p ${mountpoint}
fi

sudo mount ${device} ${mountpoint}
sudo rm -r ${mountpoint}/*
sudo cp -a targetfs/* ${mountpoint}
sudo chown -R root:root ${mountpoint}
sudo umount ${mountpoint}

sync; sync
