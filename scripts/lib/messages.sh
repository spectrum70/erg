# erg lib - messages.sh

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

function dbg {
        echo -e "\x1b[36;1m"$1"\x1b[0m"
}

function welcome {
	echo
	printf "\x1b[33;1mHello, welcome to erg !\n\n"
	cat logo
	printf "     erg v.${erg_version}\n"
	printf "     go  v.${1}\n\n"
	printf "Copyright (C) 2017 Angelo Dureghello - Sysam\x1b[0m"
	echo
}

function display_conf {
	printf "\x1b[32;1mboard: \x1b[34;1m${cfg}\n"
	if [ "x${erg_cross}" == "x" ]; then
		printf "\x1b[31;1mcross toolchain path not set, exiting.\n"
		exit 1
	fi
	cross_name=$(basename ${erg_cross})
	printf "\x1b[32;1mcross-toolchain: \x1b[34;1m${cross_name}\n"
	if [ "x${erg_hostname}" == "x" ]; then
		export erg_hostname="erg"
	fi
	printf "\x1b[32;1mtarget hostname: \x1b[34;1m${erg_hostname}\n"
	printf "\x1b[32;1march: \x1b[34;1m${arch}\n"
	printf "\x1b[32;1march_cflags: \x1b[34;1m${arch_cflags}\n"
	printf "\x1b[32;1march_ldflags: \x1b[34;1m${arch_ldflags}\n"
	printf "\x1b[32;1march_confopts: \x1b[34;1m${arch_confopts}\n"
	printf "\x1b[32;1mtarget-host: \x1b[34;1m${target_host}\n"
	printf "\x1b[32;1mconsole: \x1b[34;1m${console}\n"
	printf "\x1b[33;1m"
}

function step {
	local msglen=${#1}
	let "p=50-${msglen}"
	echo -n -e "\x1b[;1m* "$1"\x1b[0m"
}

function step_done {
	echo -e "\x1b["${p}"C\x1b[1;36m[\x1b[1;32m done \x1b[1;36m]\x1b[0m"
}
