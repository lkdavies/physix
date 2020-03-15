#!/bin/bash
source /opt/physix/include.sh || exit 1
cd $SOURCE_DIR/$1 || exit 1

su physix -c 'patch -Np1 -i ../nss-3.45-standalone-1.patch'
chroot_check $? "nss : patch"

cd nss
su physix -c 'make -j1 BUILD_OPT=1    \
  NSPR_INCLUDE_DIR=/usr/include/nspr  \
  USE_SYSTEM_ZLIB=1                   \
  ZLIB_LIBS=-lz                       \
  NSS_ENABLE_WERROR=0                 \
  $([ $(uname -m) = x86_64 ] && echo USE_64=1) \
  $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1)'
chroot_check $? "nss : make "

cd ../dist                                                          &&

install -v -m755 Linux*/lib/*.so              /usr/lib              &&
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib              &&

install -v -m755 -d                           /usr/include/nss      &&
cp -v -RL {public,private}/nss/*              /usr/include/nss      &&
chmod -v 644                                  /usr/include/nss/*    &&

install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin
chroot_check $? "nss : install /usr/include/nss/*"

install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig
chroot_check $? "nss : install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig"

install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig
chroot_check $? "nss : install /usr/lib/pkgconfig"

ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
chroot_check $? "nss : ln /usr/lib/libnssckbi.so"

