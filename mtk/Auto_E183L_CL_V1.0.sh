#!/bin/bash

###############################   用户参数设定区 起始  ############################################
CODE_PATH="repo init -u git@10.0.30.8:GR6753_65T_M0_V39_SW1/tools/manifest.git -b PDU1_Stable_Mass_ENT_CL_QB28S_P635T36V1.0.0B07_BRH"
BUILD_PROJECT=E183L_35M_CL
PRODUCT_NAME=full_E183L_35M
BUILD_PROJECT_NAME=E183L_35M
IN_VERSION=
OUT_VERSION=
#PROVINCE_INFO=
#OPERATOR_INFO=
INCREMENTAL_VERSION=
CORE=8
ACTION=new              # new or remake
VARIANT=user            # user or eng
RELEASE_PROJECT=E183L_35M
NEED_GMS=yes          # yes or no
VERSION_FILE=version35M_CL
CLEAN_CODE=no           # yes or no 更新代码时，是否需要清除build生成的文件
KK_CODE_SIGN_FOTA=yes    # yes or no android4.4代码生成差分包后重新签名

BUILD_B99=no                                                 # yes or no 不存在B99，新编么
B99_IN_VERSION=                                              # B99 内部版本号
B99_OUT_VERSION=                                             # B99 外部版本号
B99_PROVINCE_INFO=                                           # B99 其他信息
B99_OPERATOR_INFO=                                           # B99 运营商信息
B99_INCREMENTAL_VERSION=                                     # B99 额外信息

FOTA_STYLE=FOTA_ZTE             # GOTA or FOTA_ZTE or FOTA_LEWA or FOTA_ADUPS ----"GOTA" "中兴"或者"乐蛙"或者"广升"

#LEWA_PACKAGE_NAME=fota_Tcl_TCL_P728M_TD_ROM_    #如果是乐蛙FOTA，请设置"包名"
#LEWA_PACKAGE_NAME_B99=fota_Tcl_TCL_P728M_TD_ROM_14.12.30.23   #如果是乐蛙FOTA，请设置"B99包名"
###############################   用户参数设定区 结束  ############################################







###############################   脚本代码区（勿动） 起始  ############################################

MY_NAME=`whoami`
SELF_NAME=$0
BUILD_PATH="./out/target/product/$BUILD_PROJECT_NAME"
TARGET_FILES_PATH="$BUILD_PATH/obj/PACKAGING/target_files_intermediates"
#LEWA_B_PACKAGE_NAME="b_package"

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
        if [ -d ./GMS_6.0_MT6753 ]; then
        {
            cd GMS_6.0_MT6753
            git pull
        }
        else
        {
            git clone git@10.0.30.8:external/google/GMS_6.0_MT6753.git
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
            repo forall -c git clean -df
            repo forall -c git checkout .
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
        notify_done "download_code"
        return 1
    else
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少文件release_version.sh。">>Auto_build.log
        return 0
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

    if [ ! -f ./quick_build.sh ]; then
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码不完整，缺少文件quick_build.sh。">>Auto_build.log
        return 0
    fi

    if [ ! $IN_VERSION = "" ] ; then
        sed -i '1s/.*/INVER='"$IN_VERSION"'/'    ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
    if [ ! $OUT_VERSION = "" ] ; then
        sed -i '2s/.*/OUTVER='"$OUT_VERSION"'/'  ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
#    if [ ! $PROVINCE_INFO = "" ] ; then
#        sed -i '3s/.*/PROVINCE='"$PROVINCE_INFO"'/'    ./mediatek/custom/$BUILD_PROJECT_NAME/$VERSION_FILE
#    fi
#    if [ ! $OPERATOR_INFO = "" ] ; then
#        sed -i '4s/.*/OPERATOR='"$OPERATOR_INFO"'/'    ./mediatek/custom/$BUILD_PROJECT_NAME/$VERSION_FILE
#    fi
#    if [ ! $INCREMENTAL_VERSION = "" ] ; then
#        sed -i '5s/.*/INCREMENTALVER='"$INCREMENTAL_VERSION"'/'  ./mediatek/custom/$BUILD_PROJECT_NAME/$VERSION_FILE
#    fi
    
    #chmod 777 -R ./quick_build.sh
    #sed -i 's/CPUCORE=4/CPUCORE='"$CORE"'/g' ./quick_build.sh
    line=`grep -n "CPUCORE=" ./quick_build.sh | cut -d ":" -f 1`
    sed -i ''$line's/.*/    CPUCORE='"$CORE"'/' ./quick_build.sh
    
    ./quick_build.sh $BUILD_PROJECT $ACTION $VARIANT
    
    if [ -f $BUILD_PATH/system.img ]; then
        notify_done "build_code"
        return 1
    else
        echo "$(date +%Y-%m-%d_%H:%M:%S) 编译失败，未生成文件 $BUILD_PATH/system.img。">>Auto_build.log
        return 0
    fi
}

function build_T_F()
{
    notify_start "build_T_F"
    
    if [ ! -f $BUILD_PATH/system.img ]; then
        echo "$(date +%Y-%m-%d_%H:%M:%S) 代码未编译或编译失败，未生成文件 $BUILD_PATH/system.img。">>Auto_build.log
        return 0
    fi

    if [ -d $TARGET_FILES_PATH ]; then
        cd $TARGET_FILES_PATH
        for target_files in `ls $PRODUCT_NAME-target_files-*.zip`;do
            #mv $target_files XXX_$target_files
            rm -rf $target_files
        done
        cd -
    fi

    if [ -d $BUILD_PATH ]; then
        cd $BUILD_PATH
        for ota_files in `ls $PRODUCT_NAME-ota-*.zip`;do
            #mv $ota_files XXX_$ota_files
            rm -rf $ota_files
        done
        cd -
    fi

    if [ $FOTA_STYLE = "FOTA_LEWA" ] ; then
        if [ -d $BUILD_PATH ]; then
            cd $BUILD_PATH
            for lewa_files in `ls $LEWA_PACKAGE_NAME*.zip`;do
                #mv $lewa_files XXX_$lewa_files
                rm -rf $lewa_files
            done
            cd -
        fi
    fi

    #source change_java.sh 1.6
    #./makeMtk -opt=TARGET_BUILD_VARIANT=$VARIANT $BUILD_PROJECT_NAME otapackage
    ./quick_build.sh $BUILD_PROJECT otapackage $VARIANT
    
    is_bad=0
    
    if [ ! -f $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ]; then
        is_bad=1
    fi
    
    if [ ! -f $BUILD_PATH/$PRODUCT_NAME-ota-*.zip ]; then
        is_bad=1
    fi
    
    if [ $is_bad = "0" ]; then
        notify_done "build_T_F"
        return 1
    else
        echo "$(date +%Y-%m-%d_%H:%M:%S) 编译失败，未生成文件 $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ">>Auto_build.log
        echo "$(date +%Y-%m-%d_%H:%M:%S) 或 $BUILD_PATH/$PRODUCT_NAME-ota-*.zip。">>Auto_build.log
        return 0
    fi
}

function build_diff()
{
    notify_start "build_diff"
    
    if [ $BUILD_B99 = "yes" ] ; then
        build_code_B99
    fi
    
    update_a_exist=0
    update_c_exist=0
    update_exist=0
    a2b_success=1
    b2c_success=1
    success=0

    if [ $FOTA_STYLE = "FOTA_LEWA" ] ; then

        filenum=`ls ./a|wc -l`
        if [ $filenum = "1" ]; then
            if [ -f ./a/$LEWA_PACKAGE_NAME*.zip ]; then
                update_a_exist=1
                update_exist=1
            fi
        fi

        filenum=`ls ./c|wc -l`
        if [ $filenum = "1" ]; then
            if [ -f ./c/$LEWA_PACKAGE_NAME*.zip ]; then
                update_c_exist=1
                update_exist=1
            fi
        fi

        if [ ! -f $BUILD_PATH/$LEWA_PACKAGE_NAME*.zip ]; then
            update_exist=0
        fi
        
        if [ $update_exist = "1" ]; then
        {
            cd $BUILD_PATH
            for lewa_full_name in `ls $LEWA_PACKAGE_NAME*.zip`;do
                LEWA_B_PACKAGE_NAME=$lewa_full_name
            done
            cd -
            
            if [ $update_a_exist = "1" ]; then
                a2b_success=0
                rm -rf ./lewa_fota_a2b
                mkdir ./lewa_fota_a2b
                mkdir ./lewa_fota_a2b/FOTA
                cp -a $BUILD_PATH/$LEWA_B_PACKAGE_NAME ./lewa_fota_a2b/FOTA
                cp -a ./a/$LEWA_PACKAGE_NAME*.zip ./lewa_fota_a2b/FOTA
                cp -a ./build/core/LewaFota.sh ./lewa_fota_a2b
                
                source change_java.sh 1.6
                cd lewa_fota_a2b/
                ./LewaFota.sh
                cd -

                filenum=`ls ./lewa_fota_a2b/Finish/Patch|wc -l`
                if [ $filenum = "1" ]; then
                    filenum=`ls ./lewa_fota_a2b/Finish/ROM|wc -l`
                    if [ $filenum = "1" ]; then
                        a2b_success=1
                    fi
                fi
            fi

            if [ $update_c_exist = "1" ]; then
                b2c_success=0
                rm -rf ./lewa_fota_b2c
                mkdir ./lewa_fota_b2c
                mkdir ./lewa_fota_b2c/FOTA
                cp -a $BUILD_PATH/$LEWA_B_PACKAGE_NAME ./lewa_fota_b2c/FOTA
                cp -a ./c/$LEWA_PACKAGE_NAME*.zip ./lewa_fota_b2c/FOTA
                cp -a ./build/core/LewaFota.sh ./lewa_fota_b2c
                
                source change_java.sh 1.6
                cd lewa_fota_b2c/
                ./LewaFota.sh
                cd -

                filenum=`ls ./lewa_fota_b2c/Finish/Patch|wc -l`
                if [ $filenum = "1" ]; then
                    filenum=`ls ./lewa_fota_b2c/Finish/ROM|wc -l`
                    if [ $filenum = "1" ]; then
                        b2c_success=1
                    fi
                fi
            fi

            if [ $a2b_success = "1" ]; then
                if [ $b2c_success = "1" ]; then
                    success=1
                fi
            fi

            if [ $success = "1" ]; then
                notify_done "build_diff"
                return 1
            else
                echo "$(date +%Y-%m-%d_%H:%M:%S) 编译失败，未生成相应文件。">>Auto_build.log
                return 0
            fi
        }
        else
            echo "$(date +%Y-%m-%d_%H:%M:%S) 缺少a、b或者c包。">>Auto_build.log
            return 0
        fi    
    elif [ $FOTA_STYLE = "FOTA_ADUPS" ]; then
        echo "nothing to do..."
        echo "广升FOTA不支持命令编译差分包，请使用专用工具制作差分包。">>Auto_build.log
        return 1
	elif [ $FOTA_STYLE = "GOTA" ]; then 
        echo "start build GOTA diff"
        if [ -f ./update_a.zip ]; then
            update_a_exist=1
            update_exist=1
        elif [ -f ./a.zip ]; then
        {
            mv ./a.zip ./update_a.zip
            update_a_exist=1
            update_exist=1
        }
        else
            update_a_exist=0
        fi

        if [ -f ./update_c.zip ]; then
            update_c_exist=1
            update_exist=1
        elif [ -f ./c.zip ]; then
        {
            mv ./c.zip ./update_c.zip
            update_c_exist=1
            update_exist=1
        }
        else
            update_c_exist=0
        fi
        
        if [ ! -f $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ]; then
            update_exist=0
        fi

        if [ $update_exist = "1" ]; then
        {
            if [ -f ./update_b.zip ]; then
                rm -rf update_b.zip
            fi
            
            cp -a $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ./update_b.zip

            if [ $update_a_exist = "1" ]; then
                a2b_success=0
        
                if [ -f ./updateA2B.zip ]; then
                    rm -rf updateA2B.zip
                fi
				./build/tools/releasetools/ota_from_target_files  -s ./device/mediatek/build/releasetools/mt_ota_from_target_files.py --block  -n  -i update_a.zip update_b.zip updateA2B.zip
                if [ -f ./updateA2B.zip ]; then
                    a2b_success=1
                fi
            fi

            if [ $update_c_exist = "1" ]; then
                b2c_success=0

                if [ -f ./updateB2C.zip ]; then
                    rm -rf updateB2C.zip
                fi
				./build/tools/releasetools/ota_from_target_files   -s ./device/mediatek/build/releasetools/mt_ota_from_target_files.py --block -n  -i update_b.zip update_c.zip updateB2C.zip
                if [ -f ./updateB2C.zip ]; then
                    b2c_success=1
                fi
            fi

            if [ $a2b_success = "1" ]; then
                if [ $b2c_success = "1" ]; then
                    success=1
                fi
            fi

            if [ $success = "1" ]; then
                notify_done "build_diff"
                return 1
            else
                echo "$(date +%Y-%m-%d_%H:%M:%S) 编译失败，未生成相应文件。">>Auto_build.log
                return 0
            fi
        }
        else
            echo "$(date +%Y-%m-%d_%H:%M:%S) 缺少a、b或者c包。">>Auto_build.log
            return 0
        fi 	
    else
        
        if [ -f ./update_a.zip ]; then
            update_a_exist=1
            update_exist=1
        elif [ -f ./a.zip ]; then
        {
            mv ./a.zip ./update_a.zip
            update_a_exist=1
            update_exist=1
        }
        else
            update_a_exist=0
        fi

        if [ -f ./update_c.zip ]; then
            update_c_exist=1
            update_exist=1
        elif [ -f ./c.zip ]; then
        {
            mv ./c.zip ./update_c.zip
            update_c_exist=1
            update_exist=1
        }
        else
            update_c_exist=0
        fi
        
        if [ ! -f $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ]; then
            update_exist=0
        fi

        if [ $update_exist = "1" ]; then
        {
            if [ -f ./update_b.zip ]; then
                rm -rf update_b.zip
            fi
            
            cp -a $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ./update_b.zip

            if [ $update_a_exist = "1" ]; then
                a2b_success=0
        
                if [ -f ./updateA2B.zip ]; then
                    rm -rf updateA2B.zip
                fi
        
                if [ -f ./unsign_updateA2B.zip ]; then
                    rm -rf unsign_updateA2B.zip
                fi
      
 ##               source change_java.sh 1.6
                
                if [ $KK_CODE_SIGN_FOTA = "yes" ] ; then
                    ./build/tools/releasetools/ota_from_target_files  -s ./device/mediatek/build/releasetools/mt_ota_from_target_files.py  -n  --block  -i update_a.zip update_b.zip unsign_updateA2B.zip
                    java -Xmx2048m -jar out/host/linux-x86/framework/signapk.jar -w device/mediatek/common/security/$BUILD_PROJECT_NAME/releasekey.x509.pem device/mediatek/common/security/$BUILD_PROJECT_NAME/releasekey.pk8 unsign_updateA2B.zip updateA2B.zip
                else
                    ./build/tools/releasetools/ota_from_target_files   -s ./device/mediatek/build/releasetools/mt_ota_from_target_files.py -n  --block  -i update_a.zip update_b.zip updateA2B.zip
                fi

                if [ -f ./updateA2B.zip ]; then
                    a2b_success=1
                fi
            fi

            if [ $update_c_exist = "1" ]; then
                b2c_success=0

                if [ -f ./updateB2C.zip ]; then
                    rm -rf updateB2C.zip
                fi
            
                if [ -f ./unsign_updateB2C.zip ]; then
                    rm -rf unsign_updateB2C.zip
                fi
    
##                source change_java.sh 1.6

                if [ $KK_CODE_SIGN_FOTA = "yes" ] ; then
                    ./build/tools/releasetools/ota_from_target_files   -s ./device/mediatek/build/releasetools/mt_ota_from_target_files.py -n  --block  -i update_b.zip update_c.zip unsign_updateB2C.zip
                    java -Xmx2048m -jar out/host/linux-x86/framework/signapk.jar -w device/mediatek/common/security/$BUILD_PROJECT_NAME/releasekey.x509.pem device/mediatek/common/security/$BUILD_PROJECT_NAME/releasekey.pk8 unsign_updateB2C.zip updateB2C.zip
                else
                    ./build/tools/releasetools/ota_from_target_files   -s ./device/mediatek/build/releasetools/mt_ota_from_target_files.py -n  --block  -i update_b.zip update_c.zip updateB2C.zip
                fi

                if [ -f ./updateB2C.zip ]; then
                    b2c_success=1
                fi
            fi

            if [ $a2b_success = "1" ]; then
                if [ $b2c_success = "1" ]; then
                    success=1
                fi
            fi

            if [ $success = "1" ]; then
                if [ -f ./unsign_updateA2B.zip ]; then
                    rm -rf unsign_updateA2B.zip
                fi
                if [ -f ./unsign_updateB2C.zip ]; then
                    rm -rf unsign_updateB2C.zip
                fi
                notify_done "build_diff"
                return 1
            else
                echo "$(date +%Y-%m-%d_%H:%M:%S) 编译失败，未生成相应文件。">>Auto_build.log
                return 0
            fi
        }
        else
            echo "$(date +%Y-%m-%d_%H:%M:%S) 缺少a、b或者c包。">>Auto_build.log
            return 0
        fi    
    fi
}

function copy_package()
{
    notify_start "copy_package"
    
    if [ -f $BUILD_PATH/system.img ]; then
        ./release_version.sh $RELEASE_PROJECT
        filesize=`ls -lk $BUILD_PATH/system.img | awk '{print $5}'`
        echo "system.img ---- $filesize KB"
    fi
    
    rm -rf out_package
    mkdir out_package

    if [ $FOTA_STYLE = "FOTA_LEWA" ] ; then
        if [ -f ./lewa_fota_a2b/Finish/Patch/FOTA*.zip ]; then
            for file_name in ./lewa_fota_a2b/Finish/Patch/FOTA*.zip ; do
                cp -a $file_name ./out_package/${file_name##*/}.a2b
            done
        fi

        if [ -f ./lewa_fota_a2b/Finish/ROM/*.zip ]; then
            for file_name in ./lewa_fota_a2b/Finish/ROM/*.zip ; do
                cp -a $file_name ./out_package/${file_name##*/}.a2b
            done
        fi

        if [ -f ./lewa_fota_b2c/Finish/Patch/FOTA*.zip ]; then
            for file_name in ./lewa_fota_b2c/Finish/Patch/FOTA*.zip ; do
                cp -a $file_name ./out_package/${file_name##*/}.b2c
            done
        fi

        if [ -f ./lewa_fota_b2c/Finish/ROM/*.zip ]; then
            for file_name in ./lewa_fota_b2c/Finish/ROM/*.zip ; do
                cp -a $file_name ./out_package/${file_name##*/}.b2c
            done
        fi
        
        if [ -f $BUILD_PATH/$LEWA_PACKAGE_NAME*.zip ]; then
            for file_name in $BUILD_PATH/$LEWA_PACKAGE_NAME*.zip ; do
                cp -a $file_name ./out_package/${file_name##*/}.bbb
            done
        fi
        
        if [ $BUILD_B99 = "yes" ] ; then
            if [ -f ./c/$LEWA_PACKAGE_NAME*.zip ]; then
                for file_name in ./c/$LEWA_PACKAGE_NAME*.zip ; do
                    cp -a $file_name ./out_package/${file_name##*/}.ccc
                done
            fi
        fi
    elif [ $FOTA_STYLE = "FOTA_ADUPS" ]; then
        if [ -f $BUILD_PATH/target_files-package.zip ]; then
            cp $BUILD_PATH/target_files-package.zip ./out_package/
        fi    

        if [ $BUILD_B99 = "yes" ] ; then
            if [ -f ./target_files-package_B99.zip ]; then
                cp ./target_files-package_B99.zip ./out_package/
            fi
        fi
    else
        if [ -f ./updateA2B.zip ] ||  [ -f ./updateB2C.zip ]; then
            ./release_version.sh $RELEASE_PROJECT diff
        fi
        
        if [ -f $TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ] || [ -f $BUILD_PATH/$PRODUCT_NAME-ota-*.zip ]; then
            ./release_version.sh $RELEASE_PROJECT ota
        fi
        if [ $BUILD_B99 = "yes" ] ; then
            if [ -f ./update_c.zip ]; then
                cp ./update_c.zip ./out_package/
            fi
        fi
    fi
    filenum=`ls ./out_package|wc -l`
    if [ ! $filenum = "0" ]; then
    {
        for file_name in ./out_package/* ; do
            cp $file_name /data/mine/test/MT6572/$MY_NAME/
            filesize=`ls -lk $file_name | awk '{print $5}'`
            echo "$file_name ---- $filesize KB"
        done
    }
    fi
    
    rm -rf out_package
    
    notify_done "copy_package"
    
    return 1

}

function build_code_B99()
{
    notify_start "build_code_B99"
    
    path=`pwd`
    folder_old=${path##*/}
    folder_new=${folder_old}_B99
    cd ..

    #############################################
    
    echo "####################### copy folder -s #######################"

    if [ -d ./$folder_new ]; then
        rm -rf $folder_new
    fi
    
    cp -a $folder_old $folder_new
    
    echo "####################### copy folder -e #######################"

    #############################################

    echo "####################### remake B99 -s #######################"
    
    cd $folder_new
    rm out/target/product/$BUILD_PROJECT_NAME/system/build.prop

    if [ ! $B99_IN_VERSION = "" ] ; then
        sed -i '1s/.*/INVER='"$B99_IN_VERSION"'/'     ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
    if [ ! $B99_OUT_VERSION = "" ] ; then
        sed -i '2s/.*/OUTVER='"$B99_OUT_VERSION"'/'   ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
    if [ ! $B99_PROVINCE_INFO = "" ] ; then
        sed -i '3s/.*/PROVINCE='"$B99_PROVINCE_INFO"'/'     ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
    if [ ! $B99_OPERATOR_INFO = "" ] ; then
        sed -i '4s/.*/OPERATOR='"$B99_OPERATOR_INFO"'/'     ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi
    if [ ! $B99_INCREMENTAL_VERSION = "" ] ; then
        sed -i '5s/.*/INCREMENTALVER='"$B99_INCREMENTAL_VERSION"'/'   ./wind/custom_files/device/ginreen/$BUILD_PROJECT_NAME/$VERSION_FILE
    fi

    ./quick_build.sh $BUILD_PROJECT r $VARIANT

    echo "####################### remake B99 -e #######################"

    #############################################

    echo "####################### build target B99 -s #######################"
    
    if [ -d $TARGET_FILES_PATH ]; then
        cd $TARGET_FILES_PATH
        for target_files in `ls $PRODUCT_NAME-target_files-*.zip`;do
            rm -rf $target_files
        done
        cd -
    fi

    if [ -d $BUILD_PATH ]; then
        cd $BUILD_PATH
        for ota_files in `ls $PRODUCT_NAME-ota-*.zip`;do
            rm -rf $ota_files
        done
        cd -
    fi

    if [ $FOTA_STYLE = "FOTA_LEWA" ] ; then
        if [ -d $BUILD_PATH ]; then
            cd $BUILD_PATH
            for lewa_files in `ls $LEWA_PACKAGE_NAME*.zip`;do
                rm -rf $lewa_files
            done
            cd -
        fi
    fi

    ./quick_build.sh $BUILD_PROJECT otapackage $VARIANT
    
    echo "####################### build target B99 -e #######################"
    
    #############################################

    echo "####################### copy target B99 to Bxx -s #######################"
    
    if [ $FOTA_STYLE = "FOTA_LEWA" ] ; then
        cd ../$folder_old
        
        rm -rf c
        mkdir c
        
        cp ../$folder_new/$BUILD_PATH/$LEWA_PACKAGE_NAME*.zip ./c/
        mv ./c/$LEWA_PACKAGE_NAME*.zip ./c/$LEWA_PACKAGE_NAME_B99.zip
        
    elif [ $FOTA_STYLE = "FOTA_ADUPS" ]; then
        cd ../$folder_old
        
        if [ -f ./target_files-package_B99.zip ]; then
            rm -rf target_files-package_B99.zip
        fi
    
        cp ../$folder_new/$BUILD_PATH/target_files-package.zip ./target_files-package_B99.zip

    else
        cd ../$folder_old
        
        if [ -f ./update_c.zip ]; then
            rm -rf update_c.zip
        fi
    
        cp ../$folder_new/$TARGET_FILES_PATH/$PRODUCT_NAME-target_files-*.zip ./update_c.zip

    fi
    
    echo "####################### copy target B99 to Bxx -e #######################"

    #############################################

    notify_done "build_code_B99"
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
echo "3. only build T-card and Target"
echo "4. only build diff package"
echo "5. only copy package"
echo "6. select all ------ (1 2 3 4 5)"
echo -e "\033[31m7. delete all\033[0m"

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

is_exist 6
res_exist=$?
if [ $res_exist = "1" ] ; then
{
    if [ $BUILD_B99 = "yes" ] ; then
        read -n1 -p "Is space enough ? [Y/N]" answer
        case $answer in
            Y | y )
            echo "";;
            *)
            echo ""
            return;;
        esac
    fi

    read -n1 -p "Is existed update_a.zip or update_c.zip ? [Y/N]" answer
    case $answer in
        Y | y )
        echo "";;
        *)
        echo ""
        return;;
    esac

    is_exist 7
    res_exist=$?
    if [ $res_exist = "1" ] ; then
        delete_all
    fi

    download_code
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "download_code"
        return;
    fi

    build_code
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "build_code"
        return;
    fi

    build_T_F
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "build_T_F"
        return;
    fi

    build_diff
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "build_diff"
        return;
    fi

    copy_package
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "copy_package"
        return;
    fi

    return;
}
fi

is_exist 4
res_exist=$?
if [ $res_exist = "1" ] ; then

    if [ $BUILD_B99 = "yes" ] ; then
        read -n1 -p "Is space enough ? [Y/N]" answer
        case $answer in
            Y | y )
            echo "";;
            *)
            echo ""
            return;;
        esac
    fi

    read -n1 -p "Is existed update_a.zip or update_c.zip ? [Y/N]" answer
    case $answer in
        Y | y )
        echo "";;
        *)
        echo ""
        return;;
    esac
fi

is_exist 7
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

is_exist 3
res_exist=$?
if [ $res_exist = "1" ] ; then
{
    build_T_F
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "build_T_F"
        return;
    fi
}
fi

is_exist 4
res_exist=$?
if [ $res_exist = "1" ] ; then
{
    build_diff
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "build_diff"
        return;
    fi
}
fi

is_exist 5
res_exist=$?
if [ $res_exist = "1" ] ; then
{
    copy_package
    res_var=$?
    if [ $res_var = "0" ] ; then
        notify_error "copy_package"
        return;
    fi
}
fi

}

main $1 $2

###############################   脚本代码区（勿动） 结束  ############################################
