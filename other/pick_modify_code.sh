#!/bin/bash
####################Create by chusuxia for pick our modify from qcom code#######################################
                            #脚本说明#            
##脚本用于提取高通平台自己修改的文件,以方便在大版本合入出现问题时做快速比对##
##注意以下参数设置##
##   RepoXml ---- 该代码的需要处理的default.xml,通过该文件读取git的路径
##   KeyWord ---- 大版本提交注释关键字   注：大版本的提交一定需要按固定关键字，如：Qcom_base_version_upgrade
##   WhiteList --- 非高通代码的原生路径，不涉及大版本合入，在提取代码时，直接将整个文件夹拷贝出来

############################################################################################################

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#

                           #用户参数设定区#
RepoXml=.repo/manifests/default.xml
KeyWord="Qcom_base_version_upgrade|LA.UM.5.6.r1-06000-89xx.0.xml|Merge remote-tracking branch|modify linux files|Bluetooth Firmware"
WhiteList="amss/LA.UM.5.6  tools/wind/scripts  tools/wind/snapshot packages/apps/Wind  vendor/amss/binary"
BlackList="vendor/amss/binary/Z215 vendor/amss/binary/Z216"
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#

WsRootDir=`pwd`
CodePickDir=${WsRootDir%/*}/CodePick_$(date +%y%m%d)
LogsDir=$CodePickDir/Log
GitInfo=$LogsDir/GitInfo
CodeDir=$CodePickDir/Code
LogFile=$LogsDir/Execute.log

function get_gitdir()
{
    echo "get_gitdir start"
    xmlTmp1=$LogsDir/xml_Tmp1
    GitDir=$LogsDir/GitDir
    xmlTmp3=$LogsDir/xml_Tmp3
    
    grep "path=" $RepoXml > $xmlTmp1
    sed -i '/\!--/d' $xmlTmp1
    cat $xmlTmp1 | while read LINE
    do
      echo ${LINE##*=} >> $GitDir 
    done
    sed -i 's/\/>//g' $GitDir
    sed -i 's/>//g' $GitDir
    sed -i 's/"//g' $GitDir
    sed -i 's/ //g' $GitDir
    
    for whitedir in $WhiteList
    do
        mkdir -p $CodeDir/$whitedir
        cp -a $WsRootDir/$whitedir/*   $CodeDir/$whitedir/
        sed -i "s#${whitedir}##g" $GitDir
        sed -i '/^$/d' $GitDir
    done
    
    
    cat $GitDir | while read Line
    do
       
        if [ ! -d $WsRootDir/$Line ] ;then
            echo -e "\033[31m$Line is not exsit, please check your code. \033[0m"
            exit_script
        fi
    
    done
    echo "get_gitdir finished!"
}

function  pick_modify_file()
{
    echo "pick_modify_file start"
   
    cat $GitDir | while read Line
    do
   # if [ x"$Line" == x"device/qcom/common" ] ; then
        cd $WsRootDir/$Line
        gitDirName=${Line//\//_}
        gitLog_Tmp=$GitInfo/gitLog_Tmp
        gitLog=$GitInfo/gitLog_$gitDirName
        diffFileList=$GitInfo/diffFile_$gitDirName
        BaseLine_Tmp=$GitInfo/BaseLine_Tmp
        Modify_Tmp=$GitInfo/Modify_Tmp
        Delete_Tmp=$GitInfo/Delete_Tmp
        ModifyFileList=$GitInfo/ModifyFile_$gitDirName
        DeleteFileList=$GitInfo/DeleteFile_$gitDirName
        git log --pretty=oneline > $gitLog_Tmp
        declare -i LineNum
        LineNum=`sed -n '$=' $gitLog_Tmp`
        t_Num=$LineNum
        rm -rf $gitLog $diffFileList $ModifyFileList $DeleteFileList $Modify_Tmp  $Delete_Tmp
        while [ $t_Num -ne  0 ]; do
                echo `sed -n  "${t_Num}p" $gitLog_Tmp`>> $gitLog
                let "t_Num--"
        done

        echo "$gitDirName is $LineNum line(s)"
        if [ $LineNum -le 1 ]  || [ x"$LineNum" == x"" ]; then
            echo "Nothing to do"; continue
        fi
        grep  -nE  "$KeyWord" $gitLog| cut -d : -f 1 > $BaseLine_Tmp ; result=${PIPESTATUS[0]}
        if [ $result -eq  2 ] ;then
            echo "result is $result"
            exit_script
        fi
        BaseVersionLine=`cat $BaseLine_Tmp`

        echo "chusuxia  start  result=$result"
            cat $gitLog
        echo "chusuxia end"
        echo "BaseVersionLine is $BaseVersionLine"
        startLine=1
        if [ -s  $BaseLine_Tmp ] && [[ $BaseVersionLine==^\d.*\d$ ]] ; then
            BaseLine_arrary=();
            i=0
            for baseLine in $BaseVersionLine; do
                BaseLine_arrary[i++]=$baseLine
            done
            echo "i  = $i"
         

            for  BvLine in ${BaseLine_arrary[*]}; do
               echo "BvLine is $BvLine"
               endLine=$[BvLine-1]
               echo "endLine = $endLine"
               getFileList $startLine $endLine
               startLine=$BvLine
            done
        fi
          endLine=$LineNum
          getFileList $startLine $endLine
        
       if [ -s $diffFileList ] ; then
          mkdir  -p  $CodeDir/$Line
          cpCode $Line
       else 
          rm -rf  $diffFileList
       fi
   # else
 #      continue
    #fi
        
        cd  $WsRootDir
    done

    echo "pick_modify_file end"
}


function  delfile_from_blackList(){
    echo "delfile_from_blackList start"
    for blackDir  in $BlackList 
    do
        rm -rf $CodeDir/$blackDir
        echo "rm -rf $CodeDir/$blackDir"
    done

    echo "delfile_from_blackList end" 
}


function cpCode() 
{
    path=$1
    echo "line is $1"
    cat $diffFileList | while read file
    do
        flag=${file:0:1}
        filename=${file:2}
        if [ x"$flag" == x"M" ]  || [ x"$flag" == x"A" ] ; then
            echo $filename >> $Modify_Tmp
        elif [ x"$flag" == x"D" ] ; then 
            echo $filename >> $Delete_Tmp
        fi

        
    done

        if [ -s $Modify_Tmp  ] ;then
            sort -n $Modify_Tmp | uniq >>$ModifyFileList
        fi
        
        if [ -s $Delete_Tmp  ] ;then
            sort -n $Delete_Tmp | uniq >>$DeleteFileList
        fi 
        codeDir=
        if [ -s  $ModifyFileList ] ;then
            cat $ModifyFileList | while read cpFile
            do
                if [ -f $cpFile ] ;then
                    if [[ $cpFile = */* ]] ; then
                        cpCodeDir=$CodeDir/$path/${cpFile%/*}
                    else
                         cpCodeDir=$CodeDir/$path
                    fi
                    echo "chusuxia mkdir  -p $cpCodeDir" >>$LogFile
                    echo "cp $cpFile $cpCodeDir" >>$LogFile
                    mkdir  -p $cpCodeDir
                    cp $cpFile $cpCodeDir
                elif [[ $cpFile = *.txt ]] || [ "`grep $cpFile $DeleteFileList`" ] ; then
                    echo "It's normal delete."
                else
                    echo -e "\033[31m$cpFile is not exsit, please check your code. \033[0m"
                    exit_script
                fi
            done
            
        fi
        



}

exit_script()
{
    echo -e "\033[31mSome error happend, exit!!!\033[0m" 
    kill `ps  -ef|grep $0 |grep -v grep|awk '{print $2}'` 
}



function getFileList()
{
  startId=`sed -n  "${1}p" $gitLog`
  endId=`sed -n  "${2}p" $gitLog`
  git diff  --name-status  ${startId%% *} ${endId%% *} >> $diffFileList; result=$?
  if [ $result -ne 0 ] ;  then
        echo " git diff  --name-status  ${startId%% *} ${endId%% *}  in  $Line"
        exit_script
   fi

}




function init()
{
    echo "init dir"
    if  [ -d $CodePickDir ] ; then
        echo "rm -rf  $CodePickDir"
        rm -rf  $CodePickDir
    fi 
    mkdir -p $CodePickDir
    mkdir -p $LogsDir
    mkdir -p $CodeDir
    mkdir -p $GitInfo
    echo "Create dir finished `date`" > $LogFile
    
}


function main() {

    init
    get_gitdir >>$LogFile
    pick_modify_file >>$LogFile
    delfile_from_blackList >>$LogFile
    echo "Pick code finished `date`" >> $LogFile
}




main
