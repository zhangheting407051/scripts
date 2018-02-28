#!/bin/bash

repo_url="git@10.0.30.251:MSM8917_SW1/tools/manifest.git -b master"
Code_mirror=/home/chusuxia/Qcom_Code/mirror_MSM8917_SW1
Code_Name=MSM8917_SW1
commit_url="git@10.0.30.8:Qcom_SW1/get_commit.git"
RootDir=/home/chusuxia/MyScripts/AutoPickCode
CodePickDir=$RootDir/CodePick_$(date +%y%m%d)/Code
Commit_path=$RootDir/get_commit
Pick_script=pick_modify_code.sh
Log=$RootDir/$Code_Name.log


function check_exit(){
    if [ $1 -eq 0 ] ;then
        echo "Success" >>$Log
    else
        echo "$2 Error, exit."  >>$Log
        exit 1
    fi
}

echo "start `date`" >$Log
if [ -d $Commit_path ] ;then
    cd  $Commit_path
    git pull
    cd  ..
else
    git clone $commit_url
fi

if [ ! -f $Commit_path/Scripts/$Pick_script ] ;then
    echo "Error can't find $Commit_path/Scripts/$Pick_script" >>$Log
    exit 1
fi

Code_path=$RootDir/$Code_Name

rm -rf $RootDir/CodePick_*

if  [ -d  $Code_path ]; then
    rm -rf  $Code_path
fi

mkdir  -p $Code_path

cd $Code_path

echo -e "\n" | repo init -u  $repo_url --reference=$Code_mirror ; check_exit $? "repo init"
repo sync -j4  ; check_exit $? "repo sync"
repo start master --all

cp  $Commit_path/Scripts/$Pick_script  .

./$Pick_script

cd ..
 
if [ ! -d  $CodePickDir ] ; then
    check_exit 1 "Can't found  $CodePickDir"
fi

if [ -d  $Commit_path/$Code_Name ] ;then
    rm -rf  $Commit_path/$Code_Name/*
else
   mkdir -p  $Commit_path/$Code_Name
fi


cp -a  $CodePickDir/*  $Commit_path/$Code_Name/

cd  $Commit_path

git add  -A  . 
check_exit $? "git add -A ."

date_time=`date +%Y%m%d`
comments="[$date_time]Auto pick code for $Code_Name"

git commit -m  "$comments"
check_exit $? "git commit"

git push 
check_exit $? "git push"

cd  ..

echo "Pick code for $Code_Name end `date`"




