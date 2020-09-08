#!/bin/sh
# Sysam ERG - embedded rootfs generator
# Angelo Dureghello (C) 2020

go_version=0.9.4

export CMD_LINE="console=ttyS0,115200 root=/dev/ram0 rw rootfstype=ramfs rdinit=/sbin/init devtmpfs.mount=1"
export INITRAMFS="../erg/targetfs"
export DIR_ERG=${PWD}

DIR_DL=./downloads
DIR_BUILD=./build
DIR_CFG=./configs
DIR_SRC_CFG=${DIR_CFG}/sources

function err {
	echo
	echo -e "\x1b[1;31m+++ "$1"\x1b[0m"
	echo -e "\x1b[31;1;5m+++ there are errors !\x1b[0m"
	exit 1
}

function inf {
	echo -e "\x1b[1;33m"$1"\x1b[0m"
}

function msg {
	echo -e "\x1b[;1m"$1"\x1b[0m"
}

function welcome {
	echo
	echo -e "\x1b[35;1mHello, welcome to erg !\x1b[0m"
	echo -e "\x1b[;1merg v.${erg_version} " \
		"Copyright (C) 2017 Angelo Dureghello - Sysam\x1b[0m"
	echo
}

function step {
	local msglen=${#1}
	let "p=50-${msglen}"
	echo -n -e "\x1b[;1m* "$1"\x1b[0m"
}

function step_done {
	echo -e "\x1b["${p}"C\x1b[1;36m[\x1b[1;32m done \x1b[1;36m]\x1b[0m"
}

function build_checks {
	inf "preparing for building ..."

	if [ ! -e ${DIR_DL} ]; then
		mkdir -p ${DIR_DL}
	fi
	if [ ! -e ${DIR_BUILD} ]; then
		mkdir -p ${DIR_BUILD}
	fi
}

function handle_menuconfig {
	if [ "${1}" = "busybox" ]; then
		if [ -n "${busybox_reconf}" ]; then
			cp ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config \
 				${DIR_ERG}/${2}/.config
			make menuconfig
			cp .config ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config
		else
			if [ -e ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config ]; then
				cp ${DIR_ERG}/${DIR_SRC_CFG}/${1}/.config \
					${DIR_ERG}/${2}/.config
			else
				make menuconfig
			fi
		fi
	fi
}

function pkg_apply_patches {
	sources_dir=${DIR_ERG}/$1

	if [ -e ${sources_dir}/patches ]; then
		while IFS= read -r patch; do
			echo "applying ${patch} ..."
			patch -p1 < ${sources_dir}/${patch}
		done < ${sources_dir}/patches
	fi
}

function pkg_build {
	pkg=$1

	inf "package [${pkg}]: downloading ..."

	source sources/${pkg}/pkg.info

	pkg_name=${pkg_url##*/}
	pkg_dir=${DIR_BUILD}/${pkg_name%.*.*}

	if [ ! -e ${DIR_DL}/${pkg_name} ]; then
		wget ${pkg_url} --directory-prefix=${DIR_DL}
	fi
	if [ -e ${pkg_dir} ]; then
		rm -rf ${pkg_dir}
	fi

	inf "package [${pkg}]: extracting ..."

	if [ ${pkg_name: -7} == ".tar.xz" ]; then
		tar -xxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
	fi
	if [ ${pkg_name: -8} == ".tar.bz2" ]; then
		tar -jxf ${DIR_DL}/${pkg_name} --directory ${DIR_BUILD}
	fi

	inf "package [${pkg}]: configuring ..."

	cd ${pkg_dir}
	make distclean

	if [ -e "./configure" ]; then
		./configure --host=m68k
	fi

	echo "CFLAGS+=${PKG_CFLAGS}" >> Config
	echo "LDFLAGS+=${PKG_LDFLAGS}" >> Config

	# Some special packages as Busybox uses .config / menuconfig
	handle_menuconfig ${pkg} ${pkg_dir}

	inf "package [${pkg}]: patching ..."
	pkg_apply_patches sources/${pkg}

	inf "package [${pkg}]: building ..."

	make ARCH="${ERG_ARCH}" CROSS_COMPILE="${ERG_CROSS}" \
		EXTRA_CFLAGS="${PKG_CFLAGS}" EXTRA_LDFLAGS="${PKG_LDFLAGS}" \
		V=1 SKIP_STRIP="y" \
		CONFIG_PREFIX="${DIR_ERG}/targetfs" ${MAKEVARS} install
	cd -
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
	erg_cpu="-mcpu=54418"
	flat=1
	;;
	2)
	erg_cpu="-mcpu=5307,-m5307"
	flat=1
	;;
	3)
	erg_cpu="-mcpu=54418"
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

msg "Building packages ..."

build_checks
pkg_build busybox
# packages that can be built only with mmu and elf
if [ -n "${flat}" ]; then
	# pkg_build iptables
	pkg_build iproute2
fi

if [ -n "${build_kernel}" ]; then
	msg "Building kernel ..."
	# Kernel time now
	source scripts/s10-kernel.script
fi
# Rootfs
source scripts/s11-rootfs.script


msg "All ok, you are done, enjoy."
