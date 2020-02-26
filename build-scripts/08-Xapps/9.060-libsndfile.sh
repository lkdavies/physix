#!/bin/bash
source /physix/include.sh || exit 1
cd $SOURCE_DIR/$1 || exit 1

su physix -c './configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libsndfile-1.0.28'
chroot_check $? "configure"

su physix -c 'make'
chroot_check $? "make"

make install 
chroot_check $? "make install"

