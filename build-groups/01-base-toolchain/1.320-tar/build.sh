#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2019 Tree Davies
source /mnt/physix/opt/admin/physix/include.sh || exit 1
source ~/.bashrc

prep() {
	exit 0
}

config() {
	./configure --prefix=/tools
	check $? "tar: Configure"
}

build() {
	make -j8
	check $? "Tar: make"

	make check
	# Not necessary
	check $? "Tar: make check" NOEXIT
}

build_install() {
	make install
	check $? "Tar: make install"
}

[ $1 == 'prep' ]   && prep   && exit $?
[ $1 == 'config' ] && config && exit $?
[ $1 == 'build' ]  && build  && exit $?
[ $1 == 'build_install' ] && build_install && exit $?


