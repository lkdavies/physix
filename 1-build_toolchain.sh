#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2019 Travis Davies

source ./include.sh
source ./build.conf

TOOLCHAINLOGS=$BUILDROOT/var/physix/system-build-logs

IAM=`whoami`
if [ $IAM != "root" ] ; then
	report "Must run script as root."
	exit 1
fi

CWD=`pwd`
if [ ! $CWD == "$BUILDROOT/physix" ] ; then
        report "Must run from $BUILDROOT/physix"
        exit 1
fi

report "--------------------------"
report "- Building Toolchain...   "
report "--------------------------"

START_POINT=${1:-0}
STOP_POINT=`wc -l ./1-build_toolchain.csv | cut -d' ' -f1`
NUM_SCRIPTS=`ls $BUILDROOT/physix/build-scripts/$SUBTREE/ | wc -l`
BUILD_ID=0
for LINE in `cat ./1-build_toolchain.csv | grep -v -e '^#' | grep -v -e '^\s*$'` ; do
	SUBTREE=$(echo $LINE | cut -d',' -f1)
	SCRIPT=$(echo $LINE | cut -d',' -f2)
	PKG0=$(echo $LINE | cut -d',' -f3)
	PKG1=$(echo $LINE | cut -d',' -f4)
	PKG2=$(echo $LINE | cut -d',' -f5)
	PKG3=$(echo $LINE | cut -d',' -f6)


	if [ $BUILD_ID -ge $START_POINT ] && [ $BUILD_ID -le $STOP_POINT ] ; then

		TIME=`date "+%Y-%m-%d-%T"`
		report "$TIME : $BUILD_ID/$NUM_SCRIPTS : Building $PKG0 : $SCRIPT"

		if [ $PKG3 ] ; then
			unpack $PKG3 "physix:root" NCHRT
			check $? "Unpack $PKG3"
			return_src_dir $PKG3 "NCHRT"
			SRC3=$SRC_DIR
		fi

		if [ $PKG2 ] ; then
		        unpack $PKG2 "physix:root" NCHRT
		        check $? "Unpack $PKG2"
			return_src_dir $PKG2 "NCHRT"
			SRC2=$SRC_DIR

		fi

		if [ $PKG1 ] ; then
		        unpack $PKG1 "physix:root" NCHRT
		        check $? "Unpack $PKG1"
			return_src_dir $PKG1 "NCHRT"
			SRC1=$SRC_DIR

		fi

		if [ $PKG0 ] ; then
			unpack $PKG0 "physix:root" NCHRT
			check $? "Unpack $PKG0"
			return_src_dir $PKG0 "NCHRT"
			check $? "return_src_dir $PKG0"
			SRC0=$SRC_DIR
		fi

		if [ ! -e $BUILDROOT/physix/build-scripts/$SUBTREE/$SCRIPT ] ; then
			report "File not found: /build-scripts.toolchain/$SCRIPT"
			exit 1
		fi

		# Execute the build instructions.
		TIME=`date "+%Y-%m-%d-%T" | tr ":" "-"`
		su physix -c "$BUILDROOT/physix/build-scripts/$SUBTREE/$SCRIPT $SRC0 $SRC1 $SRC2 $SRC3" &> $TOOLCHAINLOGS/$TIME-$SCRIPT
		check $? "Build Complete: $SRC0 : $SCRIPT"
		echo ''

		if [ "$CONF_BUILD_SMALL" == "y" ] && [ $SRC0 ] ; then
			cd $BUILDROOT/usr/src/physix/sources/ && rm -rf ./$SRC0
		fi
	fi

	BUILD_ID=$((BUILD_ID+1))

done

/mnt/physix/physix/build-scripts/base-toolchain/1.370-chown.sh
check $? "1.370-chown.sh"

report "------------------------------------"
report "- Toolchain Build complete.        -"
report "- Next Step:                       -"
report "-   Execute: ./2-build-base-sys.sh -"
report "------------------------------------"


exit 0

