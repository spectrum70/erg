#!/bin/sh
# script:  intro.sh

clear_screen()
{
	echo -en "\033[3J" > /dev/tty1
	echo -en "\033[H" > /dev/tty1
}

blank_line()
{
	echo " " > /dev/tty1
}

msg()
{
	echo -n "${1}" > /dev/tty1
	if [ $# -gt 1 ]; then
        	sleep ${2}
	fi
}

# pwm value pause inverted

pwm()
{
	if [ $# -gt 2 ]; then
		val=$((100 - $1))
	else
		val=$1
	fi
	echo $(($val * 10000)) > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
	clear_screen
	msg "      PWM       "
	blank_line
	msg "      ${1} %    " ${2}
}

change_direction()
{
	clear_screen
	if [ $# -eq 0  ]; then
		msg " Changing  PWM  "
		msg "  direction ... " 2
	fi
	dir=`cat /sys/class/gpio/gpio4/value`
	if [ $dir == "1" ]; then
		echo 0 > /sys/class/gpio/gpio4/value
	else
		echo 1 > /sys/class/gpio/gpio4/value
	fi
}

small()
{
	pwm 0 0.2
	pwm 10 0.5
	pwm 20 0.5
	pwm 50 0.5
	pwm 70 0.5
	pwm 100 2
	pwm 0 1
	change_direction
	pwm 0 0.5 i
	pwm 10 0.5 i
	pwm 50 0.5 i
	pwm 70 0.5 i
	pwm 100 2 i
	pwm 0 1 i
	change_direction
}

init()
{
	if [ ! -e /sys/class/pwm/pwmchip0/pwm0 ]; then
		echo 0 > /sys/class/pwm/pwmchip0/export
	fi
	# period 1ms (in ns)
	echo 1000000 > /sys/class/pwm/pwmchip0/pwm0/period
	echo 0 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
	echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
	# direction gpio
	if [ ! -e /sys/class/gpio/gpio4 ]; then
		echo 4 > /sys/class/gpio/export
	fi
	echo out > /sys/class/gpio/gpio4/direction
	echo 1 > /sys/class/gpio/gpio4/value
	# stop motor
	echo 0 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
}

init

while [ 1 ]; do
	clear_screen
	cat /root/lugts/logo.raw > /dev/fb0
	small
	small
	small
	sleep 10
	clear_screen
	# 16 x 4 now
	msg "     WELCOME    " 0
	msg "      from      " 0
	blank_line
	msg "   LUG Trieste  " 3
	small
	clear_screen
	msg "In this intro   " 1
	msg "we present      " 1
	msg "a small demo    " 1
	msg "whit a cheap    " 1
	msg "Banana PI m2 0  " 1
	blank_line
	msg "Features:       " 1
	msg "- Allwinner CPU " 1
	msg "- sunxi H2+     " 1
	msg "- sdcard, wifi  " 1
	msg "- 512MDDR       " 1
	msg "- several GPIOs " 1
	blank_line
	msg "We prepared it  " 1
	msg "with an ad-hoc  " 1
	msg "real-time Linux " 1
	msg "called          " 1
	msg "  * magic OS *  " 1
	msg "with a fast boot" 1
	msg "and with a 16MB " 1
	msg "initramfs only  " 1
	msg "root file system" 3

	pwm 0 1
	pwm 10 1
	pwm 20 1
	pwm 30 1
	pwm 50 1
	pwm 70 1
	pwm 100 1
	pwm 0

	change_direction

	pwm 0 1 i
	pwm 10 1 i
	pwm 20 1 i
	pwm 30 1 i
	pwm 50 1 i
	pwm 70 1 i
	pwm 100 1 i
	pwm 0 1 i

	change_direction 0
	pwm 0
done

# Useful stuff
# mount -t debugfs none /sys/kernel/debug/
# cat /sys/kernel/debug/gpio

