#======================================================================================
#                      EDIT HISTORY FOR FILE
#
# This section contains comments describing changes made to the module.
# Notice that changes are listed in reverse chronological order.
#
# when       who             what, where, why
# --------   -----------     -----------------------------------------------------------
# 2017/10/20  zhangheting      Initial draft
#=======================================================================================
#!/bin/sh
export BUILDSPEC=KLOCWORK

export HEXAGON_ROOT=/pkg/qct/QcomCompileTools/HEXAGON_Tools/
export PATH=$HEXAGON_ROOT:$PATH
export ARMTOOLS=ARMCT6
export PATH=$ARMTOOLS:$PATH
export HEXAGON_RTOS_RELEASE=5.1.05

env
