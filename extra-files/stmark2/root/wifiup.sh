#!/bin/sh
#
# PA0 starts at gpio8
#
# RST is T0IN/PE7 8 * 5 + 7 = 47
# WAKE os T1IN/PD0 8 * 4 + 0 = 32
#

if [ ! -e /sys/class/gpio/gpio47 ]; then
        echo 47 > /sys/class/gpio/export
fi

echo out > /sys/class/gpio/gpio47/direction

printf "resetting ... "

echo 1 > /sys/class/gpio/gpio47/value
echo 0 > /sys/class/gpio/gpio47/value
echo 1 > /sys/class/gpio/gpio47/value

echo "done"

printf "waking up ... "

if [ ! -e /sys/class/gpio/gpio32 ]; then
        echo 32 > /sys/class/gpio/export
fi

echo out > /sys/class/gpio/gpio32/direction

echo 0 > /sys/class/gpio/gpio32/value
echo 1 > /sys/class/gpio/gpio32/value

echo "done"
