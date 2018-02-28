#!/bin/bash
#==========================================================================
#
#  CBSP Buils system
#
#  General Description
#     build batch file.
#
# Copyright (c) 2011 by QUALCOMM, Incorporated.
# All Rights Reserved.
# QUALCOMM Proprietary/GTDR
#
# --------------------------------------------------------------------------
#
# $Header: //components/rel/boot.bf/3.3/boot_images/build/ms/setenv.sh#2 $ 
# $DateTime: 2015/10/27 08:58:30 $
# $Author: pwbldsvc $
# $Change: 9298583 $
#                      EDIT HISTORY FOR FILE
#
#  This section contains comments describing changes made to the module.
#  Notice that changes are listed in reverse chronological order.
#
# when       who     what, where, why
# --------   ---     ---------------------------------------------------------
# 3/30/12   sy      Initial creation
# ==========================================================================

export BUILDSPEC=KLOCWORK
#=======================================
# Set up environment
#=======================================
unamestr=`uname`
if [ "$unamestr" = "Linux" ]; then

   # set up local environment
   export_armlmd_license()
   {
     # know where the host is located
     mdb $(echo `hostname`) return site > __temp.out

     # in boulder?
     grep -q "site: boulder" __temp.out
     if [ $? -eq 0 ]
     then
       echo "in boulder"
       export ARMLMD_LICENSE_FILE=8224@redcloud:8224@swiftly:7117@license-wan-arm1
     else
       # in rtp?
       grep -q "site: rtp" __temp.out
       if [ $? -eq 0 ]
       then
         echo "in rtp"
         export ARMLMD_LICENSE_FILE=8224@license-wan-rtp1
       else
         # in hyderabad?
         grep -q "site: hyderabad" __temp.out
         if [ $? -eq 0 ]
         then
           echo "in hyderabad"
           export ARMLMD_LICENSE_FILE=7117@license-hyd1:7117@license-hyd2:7117@license-hyd3
         else
           # in sandiego and others
           echo "in sandiego"
           export ARMLMD_LICENSE_FILE=7117@license-wan-arm1
         fi
       fi
     fi

     rm -f __temp.out
   }
# Set up compiler path 
#zhangheting@wind-mobi.com modifiy build env start
   #ARM_COMPILER_PATH=/pkg/qct/software/arm/RVDS/5.01bld94/sw/debugger/configdb/Boards/ARM/Cortex-A8_RTSM/linux-pentium
   export ARM_COMPILER_PATH=/pkg/qct/software/arm/RVDS/5.01bld94
   export PYTHON_PATH=/pkg/qct/software/python/2.7.5/bin
   export MAKE_PATH=/pkg/gnu/make/3.81/bin
   export ARMTOOLS=RVCT41
   export ARMROOT=/pkg/qct/software/arm/RVDS/5.01bld94
   export ARMLIB=$ARMROOT/lib
   export ARMINCLUDE=$ARMROOT/include
   export ARMINC=$ARMINCLUDE
   #export ARMCONF=$ARMROOT/sw/Debugger/configdb/Boards/ARM/Cortex-A8_RTSM/linux-pentium
  # export ARMDLL=$ARMROOT/sw/debugger/configdb/Boards/ARM/Cortex-A8_RTSM/linux-pentium
   export ARMBIN=$ARMROOT/bin
   export PATH=$MAKE_PATH:$PYTHON_PATH:$ARM_COMPILER_PATH:$PATH
   export ARMHOME=$ARMROOT
   #export_armlmd_license
#zhangheting@wind-mobi.com modifiy build env end

fi

#==============================================================================
# Dump environment to stdout so that calling scripts can read it.
#==============================================================================
env
