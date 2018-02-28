#!/bin/bash

###############################   用户参数设定区 起始  ############################################
CODE_PATH="repo init -u git@10.0.30.8:GR6737T_65_LE_N_SW1/tools/manifest.git -b PDU1"
BUILD_PROJECT=A158_EMEAD_1RAM
BUILD_PROJECT_NAME=A158
CORE=12
ACTION=new             # new or remake
VARIANT=debug            # user or eng
RELEASE_PROJECT=A158
NEED_GMS=yes          # yes or no
VERSION_FILE=versionEMEAD_1RAM
CLEAN_CODE=no           # yes or no 更新代码时，是否需要清除build生成的文件
###############################   用户参数设定区 结束  ############################################



###############################   脚本代码区（勿动） 起始  ############################################

MY_NAME=`whoami`
SELF_NAME=$0
BUILD_PATH="./out/target/product/$BUILD_PROJECT_NAME"

function delete_all()
{
    notify_start "delete_all"
    
    mkdir ./.backup
    
    if [ -f $SELF_NAME ]; then
        cp $SELF_NAME ./.backup/
    fi

    if [ -f ./a.zip ]; then    
        cp ./a.zip ./.backup/
    fi
    
    if [ -f ./update_a.zip ]; then    
        cp ./update_a.zip ./.backup/
    fi

    if [ -f ./Auto_build.log ]; then    
        cp ./Auto_build.log ./.backup/
    fi

    rm -rf *

    if [ -d ./.repo ]; then
        rm -rf ./.repo
    fi
    
    cp ./.backup/* ./
    rm -rf ./.backup
    
    notify_done "delete_all"
}

function download_code()
{
    notify_start "download_code"

    if [ $NEED_GMS = "yes" ] ; then
        ############ GMS update -s ############
        echo "GMS update -s"
        path=`pwd`
        cd ..
        if [ -d ./GMS_7.0_R12_A158_LENOVO ]; then
        {
            cd GMS_7.0_R12_A158_LENOVO
            git pull
        }
        else
        {
            git clone git@10.0.30.8:external/google/GMS_7.0_R12_A158_LENOVO.git
        }
        fi
        if [ $? != "0" ] ; then
        {
            echo "$(date +%Y-%m-%d_%H:%M:%S) 无获取GMS包权限。">>$path/Auto_build.log
            return 0
        }
        fi
        cd $path
        echo "GMS update -e"
        ############ GMS update -e ############
    fi
    
    if [ -d ./.repo ]; then
    {
        if [ $CLEAN_CODE = "yes" ] ; then
            if [ -d ./out ]; then
                rm -rf ./out
            fi
            repo forall -c 'git clean -df'
            repo forall -c 'git checkout .'
        fi
        repo sync -j4
    }
    else
    {
$CODE_PATH << EOF
EOF
        repo sync -j4
    }
    fi
    
    if [ -f ./release_version.sh ]; then
        repo start master --all
        modify_releasepath
        notify_done "download_code"
        return 1
    else
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少文件release_version.sh。">>Auto_build.log
        return 0
    fi
}
function modify_releasepath()
{
    echo "Sart to modify releasepath" >> Auto_build.log
    rm -rf version_package
    mkdir version_package 
    cpline=`grep -n /data/mine/test ./release_version.sh | cut -d ":" -f 1`
    if [ ! $cpline = "" ] ; then
    sed -i ''$cpline's/.*/    cp \$FILES  '".\/version_package"'/' ./release_version.sh
    echo "cpline is $cpline" >>Auto_build.log
    fi
}

function build_code()
{
    notify_start "build_code"
    if [ ! -d ./.repo ]; then
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少目录.repo。">>Auto_build.log
        return 0
    fi

    if [ ! -f ./release_version.sh ]; then
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少文件release_version.sh。">>Auto_build.log
        return 0
    fi

    if [ ! -f ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/version ]; then	               
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少文件wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/version。">>Auto_build.log
        return 0
    fi

    if [ ! -f ./quick_build_sign.sh ]; then
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少文件quick_build_sign.sh。">>Auto_build.log
        return 0
    fi

    if [ ! $IN_VERSION = "" ] ; then
        sed -i '1s/.*/INVER='"$IN_VERSION"'/'    ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
    if [ ! $OUT_VERSION = "" ] ; then
        sed -i '2s/.*/OUTVER='"$OUT_VERSION"'/'  ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
 
    line=`grep -n "CPUCORE=" ./quick_build_sign.sh | cut -d ":" -f 1`
    sed -i ''$line's/.*/    CPUCORE='"$CORE"'/' ./quick_build_sign.sh
    
    ./quick_build_sign.sh $BUILD_PROJECT $ACTION $VARIANT
    
    if [ -f $BUILD_PATH/system.img ]; then
        notify_done "build_code"
        return 1
    else
        echo "$(date +%Y-%m-%d_%H:%M:%S) 编译失败，未生成文件 $BUILD_PATH/system.img。">>Auto_build.log
        return 0
    fi
}






function notify_error()
{
    echo    "##############################################################################"
    echo -e "\033[31m $1 ERROR!!! ERROR!!! ERROR!!! ERROR!!! ERROR!!! ERROR!!! ERROR!!!\033[0m"
    echo    "##############################################################################"

    echo "$(date +%Y-%m-%d_%H:%M:%S) $1 ERROR">>Auto_build.log
}

function notify_start()
{
    echo "/****************************************************************************/"
    echo "/*                          $1 start"
    echo "/****************************************************************************/"

    echo "$(date +%Y-%m-%d_%H:%M:%S) $1 start">>Auto_build.log
}

function notify_done()
{
    echo "/****************************************************************************/"
    echo "/*                          $1 done"
    echo "/****************************************************************************/"

    echo "$(date +%Y-%m-%d_%H:%M:%S) $1 done">>Auto_build.log
}

function check_var()
{
case $1 in
    1) result=1 ;;
    2) result=1 ;;
    3) result=1 ;;
    4) result=1 ;;
    5) result=1 ;;
    6) result=1 ;;
    7) result=1 ;;
    *) result=0 ;;
esac

return $result
}

function is_exist()
{
case $1 in
    $var_1) result=1 ;;
    $var_2) result=1 ;;
    $var_3) result=1 ;;
    $var_4) result=1 ;;
    $var_5) result=1 ;;
    *) result=0 ;;
esac

return $result
}

function main()
{
echo -e "\033[36m/****************************************************************************/\033[0m"
echo -e "\033[36m/*                                                                          */\033[0m"
echo -e "\033[36m/*                               Auto Build                                 */\033[0m"
echo -e "\033[36m/*                                         ---V1.2 by libing                */\033[0m"
echo -e "\033[36m/*                                                                          */\033[0m"
echo -e "\033[36m/****************************************************************************/\033[0m"

echo ""

echo -e  "\033[32m##############################################################################\033[0m"
echo -e  "\033[32m#code path   : $CODE_PATH\033[0m"
echo -e  "\033[32m#project     : $BUILD_PROJECT - $BUILD_PROJECT_NAME\033[0m"
echo -e  "\033[32m#version     : $IN_VERSION - $OUT_VERSION\033[0m"
echo -e  "\033[32m#cpu core    : $CORE\033[0m"
echo -e  "\033[32m#mode        : $ACTION $VARIANT\033[0m"
echo -e  "\033[32m##############################################################################\033[0m"

echo ""

if [ ! -f Auto_build.log ]; then
:>Auto_build.log
fi
echo "">>Auto_build.log
echo "">>Auto_build.log
echo "#########################################################">>Auto_build.log
echo "$(date +%Y-%m-%d_%H:%M:%S) build time">>Auto_build.log

echo "1. only download code"
echo "2. only build code"
echo -e "\033[31m3. delete all\033[0m"

read "var_1" "var_2" "var_3" "var_4" "var_5"
#echo var_1=$var_1 var_2=$var_2 var_3=$var_3 var_4=$var_4 var_5=$var_5

echo "input command : $var_1 -- $var_2 -- $var_3 -- $var_4 -- $var_5">>Auto_build.log

check_var $var_1
res_var=$?
if [ $res_var = "0" ] ; then
var_1=""
fi

check_var $var_2
res_var=$?
if [ $res_var = "0" ] ; then
var_2=""
fi

check_var $var_3
res_var=$?
if [ $res_var = "0" ] ; then
var_3=""
fi

check_var $var_4
res_var=$?
if [ $res_var = "0" ] ; then
var_4=""
fi

check_var $var_5
res_var=$?
if [ $res_var = "0" ] ; then
var_5=""
fi

echo "valid command : $var_1 -- $var_2 -- $var_3 -- $var_4 -- $var_5">>Auto_build.log

is_exist 3
res_exist=$?
if [ $res_exist = "1" ] ; then
    delete_all
fi

is_exist 1
res_exist=$?
if [ $res_exist = "1" ] ; then
{
    download_code
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "download_code"
        return;
    fi
}
fi

is_exist 2
res_exist=$?
if [ $res_exist = "1" ] ; then
{
    build_code
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "build_code"
        return;
    fi
}
fi



}

main $1 $2

###############################   脚本代码区（勿动） 结束  ############################################
