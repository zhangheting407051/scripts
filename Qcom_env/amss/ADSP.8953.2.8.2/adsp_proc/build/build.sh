#======================================================================================
#                      EDIT HISTORY FOR FILE
#
# This section contains comments describing changes made to the module.
# Notice that changes are listed in reverse chronological order.
#
# when       who             what, where, why
# --------   -----------     -----------------------------------------------------------
#2017/10/20   zhangheting      Initial draft
#=======================================================================================
#!/bin/sh

cd `dirname $0`

# Call script to setup build environment, if it exists.
if [ -e setenv.sh ]; then
source ./setenv.sh
fi

# Call the main build command
python ./build.py -c msm8937 -o all

