#!/bin/bash

###############################   用户参数设定区 起始  ############################################
DailyBuildDir=/home1/zhangheting/DailyBuildSW1
CodeDir=$DailyBuildDir/Code
DAILYBUILDLOG=$DailyBuildDir/DailyBuild_A158.log
VersionDIR=$DailyBuildDir/Version
Date=$(date +%y%m%d)
###############################   用户参数设定区 结束  ############################################








###############################   脚本代码区（勿动） 起始  ############################################

LastDate=2000-01-01

function run_script()
{
cd $CodeDir/$FOLDER_NAME
./Auto_build_A158.sh<< EOF
1 2
EOF
echo " start pickup modify details" >> $DAILYBUILDLOG
pickup_modify
Copy_files
cd ..
}


function pickup_modify()
{
 CodeDIR=$CodeDir/$FOLDER_NAME
 Modify_File=$CodeDIR/modify.txt
 Tmp1_File=$CodeDIR/modify_tmp1.txt
 Tmp2_File=$CodeDIR/modify_tmp2.txt
 Tmp3_File=$CodeDIR/modify_tmp3.txt
 Tmp4_File=$CodeDIR/modify_tmp4.txt
 final_file=$CodeDIR/ModifyDetails_$(date +%y%m%d).txt
 cd wind

 git log --since="27 hours" >> $Modify_File
echo "$Modify_File"
 cd $CodeDIR 
 sed '/^$/d' $Modify_File > $Tmp1_File
 grep -v "commit\|Author\|Date\|Change-Id\|Merge\|Revert" $Tmp1_File > $Tmp2_File
 sed -n '/Subject/,/Ripple Effect/{/Subject/n;/Ripple Effect/b;p}' $Tmp2_File > $Tmp3_File
 grep -v "Bug Number" $Tmp3_File > $Tmp4_File
 count=0
 flag=0
 FLAG=0;
 echo "$Tmp3_File"
 cat $Tmp4_File | while read LINE
 do
 ((count+=1))
	 if !((count%2)) ;then
	  ((flag+=1))
	  BugID=$LINE
	  echo "$flag. $BugID  $Details "  >>  $final_file
	 else
	  Details=$LINE
	 fi
 done
 echo "$final_file is build!" >>$DAILYBUILDLOG
 rm -rf $Modify_File $Tmp1_File $Tmp2_File  $Tmp3_File $Tmp4_File
 chmod 777 $final_file
 cd $CodeDIR 
}

function Copy_files(){
    USER=`whoami`
	Date=$(date +%y%m%d)
    cd  $CodeDir/$FOLDER_NAME
    echo "curent pwd in Copy_files is `pwd`" >> $DAILYBUILDLOG 
    WIND_SW1_IN_VERSION_NUMBER=`awk -F = 'NR==1 {printf $2}' version`
    if [  $WIND_SW1_IN_VERSION_NUMBER = "" ] ; then
        WIND_SW1_IN_VERSION_NUMBER = $FOLDER_NAME
    fi
    BUILDTYPE=`grep -n 'ro.build.type' out/target/product/A158/system/build.prop | cut -d '=' -f 2`
    echo "'$BUILDTYPE' = $BUILDTYPE"  >> $DAILYBUILDLOG 
    cd $DailyBuildDir
    if [ ! -d Version ] ;then
      mkdir  Version    
    fi 
     cd Version
    VersionZipName=${WIND_SW1_IN_VERSION_NUMBER}_DBSW1_${Date}_${BUILDTYPE}
    mkdir $VersionZipName
	Folder_CP_name=$VersionDIR/$VersionZipName
	cp  $final_file  $Folder_CP_name
    cd   $Folder_CP_name
    cp -a  $CodeDir/${FOLDER_NAME}/version_package/*   $Folder_CP_name
    echo "cp -a  $CodeDir/${FOLDER_NAME}/version_package/*   $Folder_CP_name"  >> $DAILYBUILDLOG 
	filelist=`ls -a $Folder_CP_name`
	echo "$filelist" >> $DAILYBUILDLOG 
    for filename in $filelist
	do 
	 if [ x"$filename" == x"system-sign.img" ] ;then 
		rm -rf boot.img cache.img lk.bin logo.bin recovery.img secro.img system.img trustzone.bin userdata.img
	 fi
	done
    cd   $VersionDIR
    zip -rq $VersionZipName.zip $VersionZipName
    cp  $VersionZipName.zip  /data/mine/test/MT6572/$USER/$VersionZipName.zip
    echo "cp  $VersionZipName.zip  /data/mine/test/MT6572/$USER/$VersionZipName.zip"   >> $DAILYBUILDLOG 
    cd  $VersionDIR
    rm -rf *
}



function create_product()
{

    cd $CodeDir/
    rm -rf ${FOLDER_NAME}
    mkdir ${FOLDER_NAME}
    cp $DailyBuildDir/Auto_build_A158.sh ./${FOLDER_NAME}/
    run_script
}

function main()
{
  echo "$(date +%Y-%m-%d_%H:%M:%S) begining!!!" >> $DAILYBUILDLOG
  cd  $DailyBuildDir
  export USER=`whoami`
  Project_info=`grep  BUILD_PROJECT= ./Auto_build_A158.sh`
  echo "$Project_info" >>  $DAILYBUILDLOG
  export FOLDER_NAME=${Project_info:14:30}_${Date}
  echo "FOLDER_NAME = $FOLDER_NAME" >>  $DAILYBUILDLOG
  if [ ! -d Code ] ;then
    mkdir  Code
    cd Code
   fi 
   echo "Currentdir is `pwd`" >> $DAILYBUILDLOG
   
   case $1 in
   all)
   echo "start create product " >>$DAILYBUILDLOG
   create_product
   ;;
    *)
	;;
	esac
}

main $1

###############################   脚本代码区（勿动） 结束  ############################################
