#!/bin/bash
# Sysam ERG - embedded rootfs generator

export CMD_LINE="console=ttyS0,115200 root=/dev/ram0 rw rootfstype=ramfs rdinit=/sbin/init devtmpfs.mount=1"
export INITRAMFS="../snmdist/targetfs"

DIR_DL=./downloads
DIR_BUILD=./build

function err {
	echo -e "\x1b[1;31m+++ "$1"\x1b[0m"
	echo -e "\x1b[31;1;5m+++ there are errors !\x1b[0m"
	exit 1
}

function inf {
	echo -e "\x1b[1;33m--- "$1"\x1b[0m"
}

function msg {
	echo -e "\x1b[1;34m--- "$1"\x1b[0m"
}

function welcome {
	echo -e "\x1b[36;1mHello, welcome to erg !\x1b[0m"
	echo -e "\x1b[35;1merg v.${erg_version} Copyright (C) 2017 Angelo Dureghello - Sysam\x1b[0m"
	echo -e "\x1b[37;1mPress enter to start ...\x1b[0m"
	read -p ""
}

function step {
	local msglen=${#1}
	let "p=50-${msglen}"
	echo -n -e "\x1b[1;35m--- "$1"\x1b[0m"
}

function step_done {
	echo -e "\x1b["${p}"C\x1b[1;36m[\x1b[1;32m done \x1b[1;36m]\x1b[0m"
}

function build_checks {
	inf "preparing for building tools ..."

	if [ ! -e ${DIR_DL} ]; then
		mkdir -p ${DIR_DL}
	fi
	if [ ! -e ${DIR_BUILD} ]; then
		mkdir -p $éDIR_BUILD}
	fi
}

function build_pkg {
	pkg=$1

	inf "preparing for building ${pkg} ..."

	source sources/${pkg}/pkg.info

	pkg_name=${pkg_url##*/}
	pkg_dir=${DIR_BUILD}/${pkg_name%.*.*}

	if [ ! -e ${DIR_DL}/${pkg_name} ]; then
		wget ${pkg_url} --directory-prefix=${DIR_DL}
	fi
	if [ -e ${pkg_dir} ]; then
		rm -rf ${pkg_dir}
	fi
	if [ ${pkg_name: -7} == ".tar.xz" ]; then
		tar -xxvf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
	fi

	cd ${pkg_dir}
	make distclean
	./configure
	echo "CFLAGS+=${PKG_CFLAGS}" >> Config
	make ARCH="${ERG_ARCH}" CROSS_COMPILE="${ERG_CROSS}" EXTRA_CFLAGS="${PKG_CFLAGS}" V=1 SKIP_STRIP="y"
	cd -
}

source version

welcome

msg "Please select a cpu ..."
echo
echo "1. m68k  mcf54415 flat  (-mcpu=54418)"
echo "2. m68k  mcf5307 flat   (-mcpu=5307,-m5307)"
echo
read -n 1 c

case "$c" in
	1)
	erg_cpu="-mcpu=54418"
	;;
	2)
	erg_cpu="-mcpu=5307,-m5307"
	;;
	*)
	echo "not still implemented"
	exit 1
	;;
esac

echo

step "Setting up environment ... "
source ./configs/environment
step_done

step "Reading configurations ..."
source ./configs/cross-toolchain
source ./configs/hostname
step_done

step "Preparing targetfs tree ... "
rm -r -f targetfs
step_done

step "Creating directories ... "
source scripts/s01-create-dirs.script
step_done

step "Creating users, groups, passwd ... "
source scripts/s02-groups-passwd.script
step_done

step "Creating profile ... "
source scripts/s05-profile.script
step_done

step "Creating inittab ... "
source scripts/s06-inittab.script
step_done

step "Setting hostname ... "
source scripts/s07-hostname.script
step_done

step "Creating devices ... "
source scripts/s08-devices.script
step_done

step "Copying extra files ... "
source scripts/s09-extra.script
step_done

msg "Target fs created successfully."

step "Configuring and installing busybox ..."
cd sources/busybox-1.28.1/
make clean
make ARCH="${ERG_ARCH}" menuconfig
make ARCH="${ERG_ARCH}" CROSS_COMPILE="${ERG_CROSS}" EXTRA_CFLAGS="${erg_cpu}" EXTRA_LDFLAGS="${erg_cpu}" V=1 SKIP_STRIP="y" CONFIG_PREFIX="${CLFS}/targetfs" install
cd -

step "Configuring and installing other tools ..."

build_checks
build_pkg libnetlink
build_pkg iproute2
cd -
step_done

# Kernel time now
source scripts/s10-kernel.script

# Rootfs
source scripts/s11-rootfs.script

# Extra stuff
source scripts/s12-extra-files.script

msg "All ok, you are done, enjoy."
