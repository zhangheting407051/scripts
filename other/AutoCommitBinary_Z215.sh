#!/bin/bash

repo_url="git@10.0.30.251:MSM8917_SW1/tools/manifest.git -b master"
Code_mirror=/home/chusuxia/Qcom_Code/mirror_MSM8917_SW1
Code_Name=MSM8917_SW1
RootDir=/home/chusuxia/MyScripts/AutoCommitBinary
Code_path=$RootDir/$Code_Name
Log=$RootDir/AutoCommitBinary_$Code_Name.log
ProjectList='Z215 Z216'
BinaryPath=$Code_path/vendor/amss/binary
CORE=20

GitInfo_new=$RootDir/GitInfo_new
GitInfo_old=$RootDir/GitInfo_old
Pick_script=./tools/wind/scripts/quick_commit.sh
IsNeedCommit=no

function check_exit(){
    if [ $1 -eq 0 ] ;then
        echo "Success" >>$Log
    else
        echo "$2 Error, exit."  >>$Log
        kill `ps  -ef|grep $0 |grep -v grep|awk '{print $2}'` 
    fi
}

function Get_CleanCode(){
    if [ ! -f  $Code_path/$Pick_script ]; then
        rm -rf $Code_path
        mkdir  -p $Code_path
        cd $Code_path
        echo -e "\n" | repo init -u  $repo_url --reference=$Code_mirror ; check_exit $? "repo init"
        repo sync -j4  ; check_exit $? "repo sync"
        repo start master --all
        cd  ..
    else 
        echo "Code is exist, so revert code first" >>$Log
        cleanCode
        
        cd  $Code_path
        repo sync -j4  ; check_exit $? "Just repo sync"
    fi
}


function Get_amssGitinfo(){
    if [ -s $GitInfo_new ];then
        mv $GitInfo_new $GitInfo_old
        touch $GitInfo_new
    else
        touch $GitInfo_old
    fi
    cd  $Code_path/amss
    amss_git_path=`ls -l`
    for path in $amss_git_path 
    do
        if [ -d $path/.git ] ;then
            cd  $path
            echo "get git log form $path" >> $Log
            git  log  --pretty=oneline >>$GitInfo_new
            cd  ..
        fi
    done
    
    cd $RootDir
    rm -rf diff.patch
    diff $GitInfo_new $GitInfo_old > diff.patch
    if [ $? == 0 ]; then
        echo  "No new commit in amss, needn't commit binary" >>$Log
        IsNeedCommit=no
        exit 0
    else
        echo  "New commit in amss, need commit binary" >>$Log
        IsNeedCommit=yes
    fi
    cd ..

}

function StartCompileAmss(){

    cleanCode
    echo "StartCompileAmss $product" >>$Log
    cd  $Code_path
    line=`grep -n "CPUCORE=" ./quick_build.sh | cut -d ":" -f 1`
    sed -i ''$line's/.*/    CPUCORE='"$CORE"'/' ./quick_build.sh
    ./quick_build.sh $1 all
    cd ..
}

function StartQuickCommit(){
    product=$1
    echo "StartQuickCommit $product" >>$Log
    
    cd $BinaryPath/$product
        fileList=`ls -1`
        rm -rf *

    cd  $Code_path
$Pick_script  $1<< EOF
I
EOF
    cd  ..
    cd  $BinaryPath/$product
    for file in $fileList
    do
        if [ ! -s $file ] ; then
            check_exit 1 "$file is not in $BinaryPath/$product"
            needPush=no
        fi
    done
    
    if [ x"$needPush" != x"no" ] ;then
        echo "git push"  >> $Log
        git push; check_exit $? "git push"
    fi
    
    cd  ..
}

function cleanCode() {
    echo "start cleanCode " >>$Log
    cd $Code_path
./quick_build.sh  revert<< EOF
Y
EOF
   cd  ..
   echo "end cleanCode " >>$Log
}


function main(){
    echo "start `date`" >$Log
    Get_CleanCode
    Get_amssGitinfo
    echo "IsNeedCommit=$IsNeedCommit"
    if [ x"$IsNeedCommit" != x"yes" ] ; then check_exit 1 "No need commit"; fi
   
    for product in $ProjectList
    do
         StartCompileAmss $product
         StartQuickCommit $product
    done
    
   

    echo "end `date`" >>$Log
}





main


