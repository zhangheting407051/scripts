#!/bin/bash

###############################   �û������趨�� ��ʼ  ############################################
DailyBuildDir=/home1/zhangheting/DailyBuildSW1
DAILYBUILDLOG=/home1/zhangheting/DailyBuildSW1/DailyBuild_A158.log
###############################   �û������趨�� ����  ############################################








###############################   �ű����������𶯣� ��ʼ  ############################################


function main()
{
cd $DailyBuildDir
Project_info=`grep  BUILD_PROJECT= ./Auto_build_A158.sh`
echo "$(date +%Y-%m-%d_%H:%M:%S) begining rm 1 days ago Code" > $DAILYBUILDLOG
echo "$Project_info" >>  $DAILYBUILDLOG
project_folder=${Project_info:14:30}
delDay=$(date +%y%m%d -d "1 days ago")
cd Code
echo "date is $delDay"
echo "rm -rf *_${delDay}" >> $DAILYBUILDLOG  
rm -rf *_${delDay}
  
}

main 

###############################   �ű����������𶯣� ����  ############################################
