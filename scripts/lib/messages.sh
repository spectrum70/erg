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
