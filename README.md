Sysam CLFS based simple no-mmu distribution
Copyright (C) Sysam.it 2017 - Angelo Dureghello

This minimalized distribution is intended to be used on
embedded systems with a no-mmu processor as i.e. the ColdFire serie. 

\  1. SETUP, 2 steps
 \_____________________

1.1. Organize folders

Extract git package and create additional subfolders as below.
Following tree should result somehting like.

╰─○ ls
totale 1880
drwxr-xr-x  8 angelo angelo    4096 nov  7 09:19 .
drwxr-xr-x 37 angelo angelo    4096 nov  7 09:14 ..
drwxr-xr-x  8 angelo angelo    4096 nov  6 19:32 cross-tools
drwxr-xr-x  2 angelo angelo    4096 nov  6 23:40 extra
drwxr-xr-x  7 angelo angelo    4096 nov  7 09:19 .git
-rwxr-xr-x  1 angelo angelo    1999 nov  6 23:45 go.sh
-rw-r--r--  1 angelo angelo    1489 nov  7 09:19 README.md
drwxr-xr-x  2 angelo angelo    4096 nov  6 23:44 scripts
drwxr-xr-x  3 angelo angelo    4096 nov  5 09:53 sources
drwxr-xr-x 18 angelo angelo    4096 nov  6 23:45 targetfs
-rw-r--r--  1 angelo angelo 1880128 nov  6 23:45 uImage

This step will be automated in the future.
            

1.2. Copy your preferred uclinux binary toolchain into cross-tools:

╰─○ ls cross-tools 
totale 3144
drwxr-xr-x 8 angelo angelo    4096 nov  6 19:32 .
drwxr-xr-x 7 angelo angelo    4096 nov  6 23:49 ..
dr-xr-xr-x 2 angelo angelo    4096 nov  6 19:18 bin
-r--r--r-- 1 angelo angelo 3183992 nov  6 19:18 build.log.bz2
dr-xr-xr-x 2 angelo angelo    4096 nov  6 19:18 include
dr-xr-xr-x 4 angelo angelo    4096 nov  6 19:18 lib
dr-xr-xr-x 3 angelo angelo    4096 nov  6 19:18 libexec
dr-xr-xr-x 6 angelo angelo    4096 nov  6 18:42 m68k-sysam-uclinux-uclibc
dr-xr-xr-x 2 angelo angelo    4096 nov  6 19:18 share

\  2. Organize packages to build
 \_______________________________

Please check sources folder. Actually snmdist is set up to build
a busybox toolset only. Modify in case go.sh to build more packages.


\  3. Generate ROOTFS
 \_____________________

./go.sh

In case something goes wrong, check inside go.sh and scripts. The whole 
process is very simple. 


\  4. TO DO
 \_____________________ 

- to include packages, or allow to download them

