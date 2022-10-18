#!/bin/sh
nc -k -l 127.0.0.1 -p 9998 | hexdump -C &
zerostress -d 127.0.0.1
