Sysam - Trieste, Italy


     erg - embedded rootfs generator


Provided under the terms of the GNU General Public License v2.0 or later,
as provided in LICENSES/GPL-2.0-or-later.

Copyright (C) Sysam.it 2021 - Angelo Dureghello



Index

1. Quick start
   1.1. Create a board configuration
   1.2. Setup build variables
   1.3. Create package list
   1.4. Build
2. Introduction
3. Credits


1. Quick start

1.1. Create a board configuration

Create a configuraiton file "boards/yourboard", or check/duplicate the
boards/example configuration.


1.2. Setup build variables

In the board config file, setup at least:

  erg_cross
  target_host
  arch

Optional:

Generate initramfs

  export initramfs=1

For other available variables please check boards/example.

1.3. Create package list

Check/copy some existing package list in /pkg-list directory.
Note, available packages are visible in the sources directory. Missing
packages should be created frin time to time,

1.4. Build

./go.sh yourboard

# build a specific package

./go.sh yourboard pkg


2. Introduction

erg (all minor) is a simple rootfs (distribution, if you like it) generator,
as it means a"embedded rootfs generator". Actually, the cross-toolchain creation
is delegated to the user, very good tools as ct-ng, or openadk are available,
due to the fact that building a proper toolchain for the target is an extremly
long process, and complex too, and is actually not in the aim of this small
rootfs generator.


3. Credits

This small generator is copyright (C) of Angelo Dureghello, Sysam.
Please provide any feedback to angelo AT kernel-space.org.

Note: now a day (Sept. 2021)

Italy and Isreael seems selected from global non-voted elitarian rulers
as countries that must suffer hard dictatorial post-covid treatments.
This as always for mysterious reasons, in a "new normal" world ruled by lies.

In a better day, remember of us, now front-line fighters.
