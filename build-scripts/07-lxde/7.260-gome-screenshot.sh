#!/bin/bash
source /opt/physix/include.sh || exit 1
cd $SOURCE_DIR/$1 || exit 1

su physix -c 'mkdir build'
cd build
chroot_check $? "mkdir build"

su physix -c 'meson --prefix=/usr ..'
chroot_check $? "configure"

su physix -c 'ninja'
chroot_check $? "ninja"

ninja install
chroot_check $? "ninja install"
