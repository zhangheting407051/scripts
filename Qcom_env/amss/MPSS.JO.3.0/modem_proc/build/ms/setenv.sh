#!/bin/sh
#==========================================================================
#                      EDIT HISTORY FOR FILE
#
#  This section contains comments describing changes made to the module.
#  Notice that changes are listed in reverse chronological order.
#
# when       who              what, where, why
# --------   ------------     ---------------------------------------------------------
# 2017/10/20 zhangheting      Initial creation
# ==========================================================================
export BUILDSPEC=KLOCWORK
#=======================================
# Set up environment
#=======================================
export HEXAGON_ROOT=/pkg/qct/QcomCompileTools/HEXAGON_Tools/
export PATH=$HEXAGON_ROOT:$PATH
export ARMTOOLS=ARMCT6
export PATH=$ARMTOOLS:$PATH
export HEXAGON_RTOS_RELEASE=6.4.06


#==============================================================================
# Dump environment to stdout so that calling scripts can read it.
#==============================================================================
env
