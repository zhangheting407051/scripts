#===============================================================================
#
# CBSP Buils system
#
# General Description
#    build shell script file.
#
# Copyright (c) 2014 by QUALCOMM, Incorporated.
# All Rights Reserved.
# QUALCOMM Proprietary/GTDR
#
#-------------------------------------------------------------------------------
#
# $Header: //components/rel/boot.bf/3.3/boot_images/build/ms/build_8937.sh#1 $
# $DateTime: 2015/07/06 06:13:34 $
# $Author: pwbldsvc $
# $Change: 8523009 $
#                      EDIT HISTORY FOR FILE
#
# This section contains comments describing changes made to the module.
# Notice that changes are listed in reverse chronological order.
#
# when       who     what, where, why
# --------   ---     -----------------------------------------------------------
# 09/29/14   lm      Initial draft
#===============================================================================
#!/bin/bash

#===============================================================================
# Set up default paths
#===============================================================================
build_dir=`dirname $0`
cd $build_dir
export BUILD_ROOT=../..
export TOOLS_SCONS_ROOT=$BUILD_ROOT/tools/build/scons
export PARTITION_TOOLS_ROOT=$BUILD_ROOT/core/storage/tools/nandbootmbn
LOGNAM=`basename $0`

#----- reset images-----
unset IMAGES
#===============================================================================
#Call setenv if existed 
#===============================================================================
if [ -e "setenv.sh" ]; then 
#zhangheting@wind-mobi.com add 20171023 start
    source ./setenv.sh
#zhangheting@wind-mobi.com add 20171023 end
fi 

# -------------------Set target enviroment ----------------
#Parse command input
while [ $# -gt 0 ]
do
    case "$1" in 
	BUILD_ID=*) 
		BUILD_ID=${1#BUILD_ID=}
		;;
	BUILD_VER=*) 
		BUILD_VER=${1#BUILD_VER=}
		 ;;
	MSM_ID=*) 
		MSM_ID=${1#MSM_ID=} 
		;; 
	HAL_PLATFORM=*) 
		HAL_PLATFORM=${1#HAL_PLATFORM=}
		;;
	TARGET_FAMILY=*) 
		TARGET_FAMILY=${1#TARGET_FAMILY=}
		;;
	BUILD_ASIC=*) 
		BUILD_ASIC=${1#BUILD_ASIC=}
		;;
	CHIPSET=*) 
		CHIPSET=${1#CHIPSET=}
		;;
	 --prod)
                cmds=${cmds//--prod/}
		BUILD_ID=SAAAANAZ
		;;
	*)
		IMAGES="$IMAGES $1"
		;;
    esac
    shift
done 

#------- if not define, set default value ----
BUILD_ID=${BUILD_ID:-FAASANAA}
BUILD_VER=${BUILD_VER:-40000000}
#export BUILDSPEC=KLOCWORK

BUILD_ASIC=${BUILD_ASIC:-8937A}
MSM_ID=${MSM_ID:-8937}
HAL_PLATFORM=${HAL_PLATFORM:-8937}
TARGET_FAMILY=${TARGET_FAMILY:-8937}
CHIPSET=${CHIPSET:-msm8937}


export BUILD_CMD="BUILD_ID=$BUILD_ID BUILD_VER=$BUILD_VER MSM_ID=$MSM_ID HAL_PLATFORM=$HAL_PLATFORM TARGET_FAMILY=$TARGET_FAMILY BUILD_ASIC=$BUILD_ASIC CHIPSET=$CHIPSET  $IMAGES"

echo $BUILD_CMD

#Create build log, and compile
$TOOLS_SCONS_ROOT/build/rename-log.sh ${LOGNAM%.*}
#$TOOLS_SCONS_ROOT/build/build.sh -f $TOOLS_SCONS_ROOT/build/start.scons --tcfgf=9x15.target.builds CFLAGS=--mno-pullup $BUILD_CMD 
$TOOLS_SCONS_ROOT/build/build.sh -f target.scons --tcfgf=8937.target.builds  $BUILD_CMD

#zhangheting@wind-mobi.com add 20171023 start
if [[ $? == 0 ]]; then
    echo -e "Successfully compile 8937"
fi
#zhangheting@wind-mobi.com add 20171023 end
#if there is an error stop compiling
if [[ $? != 0 ]]; then
    echo -e "Fail to compile 8937. Exiting ....."
    exit 1
fi 

#rename default build log
#mv build-log.txt ${LOGNAM%.*}-log.txt 

#exit 0
