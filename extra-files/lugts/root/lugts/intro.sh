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

pwm()
{
	if [ $# -gt 1 ]; then
		val=$((100 - $1))
	else
		val=$1
	fi
	echo $(($val * 10000)) > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
	clear_screen
	msg "      PWM       "
	blank_line
	msg "      ${1} %    " 3
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
	sleep 10
	clear_screen
	# 16 x 4 now
	msg "     WELCOME    " 0
	msg "      from      " 0
	blank_line
	msg "   LUG Trieste  " 3
	clear_screen
	msg "In this intro   " 1
	msg "we present      " 1
	msg "a small demo    " 1
	msg "whit a cheap    " 1
	msg "banana pi m2 0  " 1
	msg "features:       " 1

	msg "Allwinner CPU,  " 1
	msg "sunxi H3        " 1
	msg "sdcard, wifi    " 1
	msg "512MDDR         " 1
	msg "several GPIOs   " 1
	blank_line
	msg "we prepared it  " 1
	msg "with an ad-hoc  " 1
	msg "real-time Linux " 1
	msg "called          " 1
	msg " magic OS (RT)  " 1
	msg "with a fast boot" 1
	msg "and with a 16MB " 1
	msg "initramfs only  " 3

	pwm 0
	pwm 10
	pwm 20
	pwm 30
	pwm 50
	pwm 70
	pwm 100
	pwm 0

	change_direction

	pwm 0 i
	pwm 10 i
	pwm 20 i
	pwm 30 i
	pwm 50 i
	pwm 70 i
	pwm 100 i
	pwm 0 i

	change_direction 0
	pwm 0
done

# Useful stuff
# mount -t debugfs none /sys/kernel/debug/
# cat /sys/kernel/debug/gpio

