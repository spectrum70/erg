#!/bin/bash
#
# creating a initramfs
# initrd is the old way (ram disk, block device needed)
# initramfs is the new way, all in ram

if [ $# -ne 1 ]; then
	echo "usage: mkramfs device"
	exit -1
fi

ramfs=targetfs
sz_megabytes=32768
card_dev=${1}

echo "creating uRamdisk (on $card_dev, from ${ramfs})"

rm -f initramfs.* uRamfs
sudo rm -r -f ramfs

echo creating initramfs rootfs
cd ${ramfs}; find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | gzip > initramfs.cpio.gz
sync
mkimage -A arm -O linux -T ramdisk -C gzip -n 'initramfs image' -d initramfs.cpio.gz uRamfs

sudo mount ${card_dev} /media/rootfs
if [ $? != 0 ]; then
	echo "mount faield, exiting"
	exit 1
fi
sync

sudo cp -f uRamfs /media/rootfs/uRamfs
sudo umount ${card_dev}
sync

# sudo rm -rf initramfs.cpio initramfs.cpio.gz

echo "done"
