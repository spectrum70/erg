Sysam Italia

     erg - embedded rootfs generator

Copyright (C) Sysam.it 2020 - Angelo Dureghello


This minimalized distribution is intended to be used on embedded 
systems as a very basic rootfs generator, started up for no-mmu 
processors as i.e. the ColdFire serie, but with ambition to be expanded
to other architectures. 

1. Quick start

./go.sh

An interactive menu will ask architecture and SoC/cpu tu build for.

2. Setup

Cross toolchain path is actually manually set in configs/cross-toolchain..
Other useful things can be set manually over configs/ files.

3. Packages

A part cor current special case of busybox, all other packages details
needs to be added in sources folder, as .info details.


4. TO DO

Really a lot
