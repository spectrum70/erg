#!/bin/bash
# Sysam ERG - embedded rootfs generator
# Angelo Dureghello (C) 2020

set -e

source scripts/lib/messages.sh
source scripts/lib/packages.sh

go_version=0.9.8

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
	echo "Usage: ./go.sh config [option]"
	echo "Options: -h --help      shows this help"
	echo "         -k --kernel    build kernel and modules"
	echo "         -c --config    force busybox reconfig"
	echo "Example:"
	echo "         ./go.sh stmak2"
	exit 1
}

if [ $# -gt 3 ]; then
	usage
fi

options=$(getopt -n "$0" -o hkc --long "help,kernel,config"  -- "$@")

if [ $? -ne 0 ]; then usage; fi

# A little magic, necessary when using getopt.
eval set -- "$options"

while true;
do
	case "$1" in
	-h | --help)
		usage
		;;
	-k | --kernel)
		build_kernel=1
		shift
		break;;
	-c | --config)
		busybox_reconf=1
		shift
		break;;
	--)
		break;;
	esac
done

shift $(($OPTIND - 1))

cfg=$2
package=$3

if [ "${cfg}" == "" ]; then
	echo "configuration missing"
	usage
fi

# Cleanup
unset erg_cross
unset erg_hostname
unset target_host
unset arch
unset arch_cflags
unset arch_ldflags
unset arch_confopts

source ./version
welcome $go_version
echo

if [ ! -e boards/${cfg} ]; then
	err "board config missing, exiting."
fi

if [ ! -e ${DIR_PKG_LST}/pkgs-${cfg}.list ]; then
	err "board package list missing, exiting."
fi

source boards/${cfg}
list=${DIR_PKG_LST}/pkgs-${cfg}.list

display_conf

read -n 1 -r -s -p $'\npress a key to start\n'

echo

step "setting up environment ... "
source ./configs/environment
step_done

step "reading configurations ..."
step_done

step "Preparing targetfs tree ... "
sudo rm -r -f targetfs
step_done

step "creating directories ... "
source scripts/s01-create-dirs.script
step_done

step "creating users, groups, passwd ... "
source scripts/s02-groups-passwd.script
step_done

step "creating profile ... "
source scripts/s05-profile.script
step_done

step "creating inittab ... "
source scripts/s06-inittab.script
step_done

step "setting hostname ... "
source scripts/s07-hostname.script
step_done

step "creating devices ... "
source scripts/s08-devices.script
step_done

step "copying extra files ... "
source scripts/s09-extra.script
step_done

echo

export ARCH=${arch}

build_checks

if [ "x${package}" != "x" ]; then
	msg "building ${package}..."
	pkg_set ${list} ${package}
	exit 0
fi

msg "building packages ..."

if [ -z "${list}" ]; then
	err "package list not defined, exiting ..."
fi

pkg_build_pkg_list ${list}

if [ -n "${build_kernel}" ]; then
	msg "building kernel ..."
	# Kernel time now
	source scripts/s10-kernel.script
fi

# Rootfs
source scripts/s11-rootfs.script

msg "all ok, you are done, enjoy"
