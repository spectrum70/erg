#!/bin/sh

msg() {
	echo -e "\x1b[33;1m${1}\x1b[0m"
}

msg "saving kernel crashdump to sd card ..."
msg "mounting needed stuff ..."
mount -t proc proc /proc
mount /dev/mmcblk0p2 /mnt/logs
msg "saving vmcore ..."
dd if=/proc/vmcore of=/mnt/logs/vmcore bs=1M conv=fsync
msg "saving done, unmounting and syncing ..."
umount /mnt/logs
sync; sync
msg "success, all done, halting system."
# go looping
while [ true ]; do sleep 1; done

