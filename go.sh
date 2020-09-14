#!/bin/sh
# Sysam ERG - embedded rootfs generator
# Angelo Dureghello (C) 2020

source scripts/lib/messages.sh
source scripts/lib/packages.sh

go_version=0.9.6

export CMD_LINE="console=ttyS0,115200 root=/dev/ram0 rw rootfstype=ramfs rdinit=/sbin/init devtmpfs.mount=1"
export INITRAMFS="../erg/targetfs"
export DIR_ERG=${PWD}

DIR_DL=./downloads
DIR_BUILD=./build
DIR_CFG=./configs
DIR_SRC_CFG=${DIR_CFG}/sources
DIR_PKG_LST=./pkg-list


function build_checks {
	inf "preparing for building ..."

	if [ ! -e ${DIR_DL} ]; then
		mkdir -p ${DIR_DL}
	fi
	if [ ! -e ${DIR_BUILD} ]; then
		mkdir -p ${DIR_BUILD}
	fi
}

function usage {
	echo "go.sh, erg build system helper v." ${go_version}
	echo "Angelo Dureghello (C) sysam.it 2019, 2020"
	echo "Usage: ./go.sh [option]"
	echo "Options: -h --help      shows this help"
	echo "         -k --kernel    build kernel and modules"
	echo "         -c --config    force busybox reconfig"
	exit 1
}

options=$(getopt -n "$0" -o hkc --long "help,kernel,config"  -- "$@")

if [ $? -ne 0 ]; then exit 1; fi

# A little magic, necessary when using getopt.
eval set -- "$options"

while true;
do
	case "$1" in
	-h | --help)
		usage
		;;
	--k | --kernel)
		build_kernel=1
		break;;
	--c | --config)
		busybox_reconf=1
		break;;
	--)
		shift
		break;;
	esac
done

source ./version

welcome

msg "Please select a configuration ..."
echo
echo "n. ARCH  CPU/SoC   binary"
echo
echo "1. m68k  mcf54415  flat    (-mcpu=54418)"
echo "2. m68k  mcf5307   flat    (-mcpu=5307,-m5307)"
echo "3. m68k  mcf54415  elf     (-mcpu=54418)"
read -s -n 1 c

case "$c" in
	1)
	arch=m68k
	target_host=m68k-linux
	arch_cflags="-mcpu=54418"
	flat=1
	;;
	2)
	arch=m68k
	target_host=m68k-linux
	arch_cflags="-mcpu=5307,-m5307"
	flat=1
	;;
	3)
	arch=m68k
	target_host=m68k-linux
	arch_cflags="-mcpu=54418"
	list=${DIR_PKG_LST}/pkgs-stmark2.list
	flat=0
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
source ./configs/board-support
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

echo

export ARCH=${arch}

msg "Building packages ..."

if [ -z "${list}" ]; then
	err "package list not defined, exiting ..."
fi

build_checks
pkg_build_pkg_list ${list}

if [ -n "${build_kernel}" ]; then
	msg "Building kernel ..."
	# Kernel time now
	source scripts/s10-kernel.script
fi
# Rootfs
source scripts/s11-rootfs.script


msg "All ok, you are done, enjoy."
