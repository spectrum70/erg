#!/bin/bash
# Sysam snmdist - CLFS based simple no-mmu rootfs generator

export CLFS=`pwd`
export PATH="$PATH:${CLFS}/cross-tools/bin"
export CLFS_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
export CLFS_TARGET="m68k-linux-musl"
export CLFS_ARCH=m68k

function err {
        echo -e "\x1b[1;31m+++ "$1"\x1b[0m"
        echo -e "\x1b[31;1;5m+++ there are errors !\x1b[0m"
        exit 1
}

function inf {
        echo -e "\x1b[1;34m--- "$1"\x1b[0m"
}

function msg {
        echo -e "\x1b[1;33m--- "$1"\x1b[0m"
}

function step {
	local msglen=${#1}
	let "p=50-${msglen}"
	echo -n -e "\x1b[1;35m--- "$1"\x1b[0m"
}

function step_done {
	echo -e "\x1b["${p}"C\x1b[1;36m[\x1b[1;32m done \x1b[1;36m]\x1b[0m"
}

msg "Greetings, you are using Sysam snmdist (simple no-mmu distribution) !"
msg "Copyright (C) 2017 Angelo Dureghello - Sysam"
msg "Please visit http://www.sysam.it for further details"
msg "Press enter to start ..."
read -p ""

msg "Please select a cpu ..."
echo "1. mcf54415 flat  (-mcpu=54418)"
echo "2. mcf5475        (-mcpu=5475,-m5200)"
echo "3. mcf5407        (-mcpu=5407,-m5200)"
echo "4. mcf5307        (-mcpu=5307,-m5307)"
echo "5. mcf537x        (-mcpu=537x,-m5200)"
echo "6. mcf528x        (-mcpu=528x,-m5307)"
echo "7. mcf5271        (-mcpu=5271,-m5307)"
echo "8. mcf5272        (-mcpu=5272,-m5307)"
echo "9. mcf5275        (-mcpu=5275,-m5307)"
echo "a. mcf523x        (-mcpu=523x,-m5307)"
echo "b. mcf5253        (-mcpu=5253,-m5200)"
echo "c. mcf5249        (-mcpu=5249,-m5200)"
echo "d. mcf5206        (-mcpu=5206,-m5200)"
echo "e. mcf5206e       (-mcpu=5206e,-m5200)"
echo "f. mcf520x        (-mcpu=5208,-m5200)"

read -n 1 c

case "$c" in
	1)
	clfs_cpu="-mcpu=54418 -Os"
	;;
	4)
	clfs_cpu="-mcpu=5307,-m5307 -Os"
	;;
esac

echo -e "\n"
step "Selecting cpu ... "
step_done

step "Setting up environment ... "
source scripts/s0-setup.script
step_done

step "Preparing targetfs tree ... "
rm -r -f targetfs
step_done

step "Creating directories ... "
source scripts/s1-create-dirs.script
step_done

step "Creating users, groups, passwd ... "
source scripts/s2-groups-passwd.script
step_done

#-rw-r--r-- 1 angelo angelo  178 nov  5 01:10 s3-inst-libgcc.script
#-rw-r--r-- 1 angelo angelo 3072 nov  5 10:00 s4-mdev.script

step "Creating profile ... "
source scripts/s5-profile.script
step_done

step "Creating inittab ... "
source scripts/s6-inittab.script
step_done

step "Setting hostname ... "
source scripts/s7-hostname.script
step_done

step "Creating devices ... "
source scripts/s8-devices.script
step_done

step "Copying extra files ... "
source scripts/s9-extra.script
step_done

msg "Target fs created successfully."

step "Configuring and installing busybox ... \n"
cd sources/busybox-1.24.2/
make clean
make ARCH="${CLFS_ARCH}" menuconfig
make ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" CFLAGS="${clfs_cpu}" V=1 SKIP_STRIP="y" CONFIG_PREFIX="${CLFS}/targetfs" install
cd -
step "Configuring and installing busybox ... "
step_done

step "Building Linux and initramfs ... \n"
cd sources/linux
./build.sh
if [ $? == 0 ]; then
	cp -f uImage ${CLFS}
fi
cd -
step "Building Linux and initramfs ... "
step_done

msg "All ok, you are done, enjoy."
