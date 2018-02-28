#!/bin/bash
#######################################################################################################################
###      编译命令: AP端默认编译eng版本，如需编译其它版本，请添加对应参数（user,debug,默认userdebug）                ####
###  cse参数：工厂版本必须添加这个参数，默认关闭eng和userdebug版本上的seLinux，否则影响工模音频回路测试和标志位读写 ####
###           all: ./quick_build.sh Z215/Z216   all n                                    ####
###qfil(正常版本): ./quick_build.sh Z215/Z216   qfil
###qfil(工厂版本): ./quick_build.sh Z215/Z216   factory
###     all clean: ./quick_build.sh Z215/Z216   all c                                ####
###          amss: ./quick_build.sh Z215/Z216   amss                                ####
###          boot: ./quick_build.sh Z215/Z216   boot                                ####
###          mpss: ./quick_build.sh Z215/Z216   mpss                                ####
###        rpm_proc: ./quick_build.sh Z215/Z216 rpm_proc                            ####
###            tz: ./quick_build.sh Z215/Z216   tz                                ####
###          adsp: ./quick_build.sh Z215/Z216   adsp                                ####
###        common: ./quick_build.sh Z215/Z216   common                                ####
###          AP端: ./quick_build.sh Z215/Z216 n  （若命令中参数ACTION不为null，均会编译AP端代码）        ####
###    AP端kernel: ./quick_build.sh Z215/Z216 n k                                ####
###        AP端lk: ./quick_build.sh Z215/Z216 n lk                                ####
###      AP端模块: ./quick_build.sh Z215/Z216 mmm 模块路径                             ####
###  魅族指令(Z216):  ./quick_build.sh M1810 n  user                                                             ####
###  魅族指令(Z215):  ./quick_build.sh M1810M n  user                                                            ####
#######################################################################################################################

WsRootDir=`pwd`
MY_NAME=`whoami`
amssPath=$WsRootDir/amss
CONFIGPATH=$WsRootDir/device/ginreen
ARM=arm64
CUSTOMPATH=$WsRootDir/device/ginreen
RELEASEPATH=$1
ADDGMS=false
RELEASE_PARAM=none
LOG_PATH=$WsRootDir/build-log
CPUCORE=16
MEIZU=false
MODEM=
EFUSE=



PRODUCT=
VARIANT=
ACTION=
MODULE=
ORIGINAL=
CONFIG_NAME=
#add by chenshu@wind-mobi.com 20171211 start
WIND_OPTR_NAME_CUSTOM=
#add by chenshu@wind-mobi.com 20171211 end
BUILD_MODE=
CLEAN=

clean_kernel()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/k.log; make kernelclean
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        KERNEL_OUT_PATH=$OUT_PATH/obj/KERNEL_OBJ
        rm -f $LOG_PATH/k.log
        rm -f $OUT_PATH/boot.img
        rm -rf $KERNEL_OUT_PATH
        result=$?
        return $result
    fi
}
build_kernel()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE kernel 2>&1 | tee $LOG_PATH/k.log
        return $?
    else
        cd kernel/msm-3.18
        kernelproduct=$PRODUCT
        if [ x"64" == x"$(echo $PRODUCT | sed -r 's/^.+_//')" ];then
            kernelproduct=$(echo $CONFIG_NAME | sed -r 's/_[^_]+$//')
        fi
        echo "kernelproduct=$kernelproduct"
        if [ x$VARIANT == x"user" ]; then
            defconfig_files=${kernelproduct}-perf_defconfig
        else
            defconfig_files=${kernelproduct}_defconfig
        fi
        KERNEL_OUT_PATH=../../out/target/product/$PRODUCT/obj/KERNEL_OBJ
        mkdir -p $KERNEL_OUT_PATH
        while [ 1 ]; do
            make O=$KERNEL_OUT_PATH ARCH=$ARM ${defconfig_files}
            result=$?; if [ x$result != x"0" ];then break; fi
            #make -j$CPUCORE -k O=$KERNEL_OUT_PATH Image modules
        if [ x$ARM == x"arm" ];then
            make -j$CPUCORE O=$KERNEL_OUT_PATH ARCH=$ARM CROSS_COMPILE=$WsRootDir/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- 2>&1 | tee $LOG_PATH/k.log
            else
        make -j$CPUCORE O=$KERNEL_OUT_PATH ARCH=$ARM CROSS_COMPILE=$WsRootDir/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android- 2>&1 | tee $LOG_PATH/k.log
        fi
        result=$?; if [ x$result != x"0" ];then break; fi
            if [ x$ARM == x"arm" ];then
            cp $KERNEL_OUT_PATH/arch/arm/boot/zImage ../../out/target/product/$PRODUCT/kernel
            else
            cp $KERNEL_OUT_PATH/arch/arm64/boot/Image.gz ../../out/target/product/$PRODUCT/kernel
            fi
            break
        done
        cd -
        cp $OUT_PATH/kernel /data/mine/test/MT6572/$MY_NAME/
        return $result
    fi
}

clean_lk()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/lk.log; make emmc_appsbootldr_clean
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        LK_OUT_PATH=$OUT_PATH/obj/EMMC_BOOTLOADER_OBJ
        rm -f $LOG_PATH/lk.log
        rm -f $OUT_PATH/lk.bin $OUT_PATH/logo.bin
        rm -rf $LK_OUT_PATH
        result=$?
        return $result
    fi
}

build_lk()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE aboot 2>&1 | tee $LOG_PATH/lk.log
        return $?
    else
        bootloaderproduct=
        if [ x"msm8937" == x"$(echo $PRODUCT | sed -r 's/_[^_]+$//')" ];then
            bootloaderproduct=msm8952
        fi
        echo "bootloaderproduct=$bootloaderproduct"
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        LK_OUT_PATH=$OUT_PATH/obj/EMMC_BOOTLOADER_OBJ
        mkdir -p $LK_OUT_PATH
        cd bootable/bootloader/lk
        #export BOOTLOADER_OUT=$LK_OUT_PATH
        #export MTK_PUMP_EXPRESS_SUPPORT=yes
        make -j$CPUCORE TOOLCHAIN_PREFIX=$WsRootDir/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- BOOTLOADER_OUT=$LK_OUT_PATH $bootloaderproduct 2>&1 | tee $LOG_PATH/lk.log
        result=$?
        cd -
        cp $LK_OUT_PATH/build-$bootloaderproduct/lk.bin $OUT_PATH
        #cp $LK_OUT_PATH/build-$bootloaderproduct/logo.bin $OUT_PATH
        cp $OUT_PATH/lk.bin /data/mine/test/MT6572/$MY_NAME/
        return $result
    fi
}


revert_code()
{
    echo -e "\033[33mIt's going to revert your code.\033[0m"
    read -n1 -p  "Are you sure? [Y/N]" answer
    case $answer in
        Y | y )
        echo "";;
        *)
    echo -e "\n"
        exit 0 ;;
    esac
   echo "Start revert Code...."
   echo "repo forall -c \"git clean -df\""
   repo forall -c  "git clean -df"
   echo "repo forall -c \"git checkout .\""
   repo forall -c "git checkout ."
   echo "rm -rf $LOG_PATH/*"
   rm -rf $LOG_PATH/*
   echo "rm -rf out"
   rm -rf out
   echo -e "\033[33mComplete revert code.\033[0m"
   exit 0
}

function build_efuse()
{
    echo -e "\033[40;32m Build efuse start \033[0m"
    cd $WsRootDir/amss/MSM8917.LA.3.0/common/sectools
    python sectools.py fuseblower -e config/8917/8917_fuseblower_OEM.xml -q config/8917/8917_fuseblower_QC.xml -u config/8917/8917_fuseblower_USER.xml -g verbose –vvv
    ./sign_all.sh
    ./recopy_all.sh
    echo -e "\033[40;32m Build efuse end \033[0m"
}

function build_android()
{
    cd $WsRootDir
    if [ x$VARIANT == x"" ];then VARIANT=userdebug; fi
    if [ x$ORIGINAL == x"" ];then ORIGINAL=yes; fi
    if [ x$ACTION == x"clean" ];then RELEASE_PARAM=none; fi

    echo "********This build project CONFIG_NAME is $CONFIG_NAME********"
    echo "PRODUCT=$PRODUCT VARIANT=$VARIANT ACTION=$ACTION MODULE=$MODULE ORIGINAL=$ORIGINAL CLEAN=$CLEAN "
    echo "Log Path $LOG_PATH"

    if [ x$PRODUCT == x"" ];then
        echo  -e "\033[31m !!!!!!   No Such Product   !!!! \033[0m"
        exit 1
    fi
    if [ x$ACTION == x"" ];then
        echo  -e "\033[31m !!!!!!   No Such Action   !!!! \033[0m"
        exit 1
    fi

    ##################################################################
    #Check Space
    ##################################################################

    Check_Space

    ##################################################################
    #Add GMS
    ##################################################################
    if [ x"$ADDGMS" == x"true" ];then
        if [ x$ACTION == x"new" ];then
            if [ x$MODULE == x"" ];then
                addGMS
            fi
        fi
    fi

    ###################################################################
    #Start build
    ###################################################################
    echo "Build started `date +%Y%m%d_%H%M%S` ..."
    echo;echo;echo;echo
    export PATH="/usr/lib/jvm/java-8-openjdk-amd64/bin":$PATH

    source build/envsetup.sh

    lunch $PRODUCT-$VARIANT

    OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
    case $ACTION in
        new | remake | clean)

        M=false; C=false;
        if [ x$ACTION == x"new" ];then M=true; C=true;
        elif [ x$ACTION == x"remake" ];then
          M=true;
          find $OUT_PATH/ -name 'build.prop' -exec rm -rf {} \;
      find $OUT_PATH/ -name 'default.prop' -exec rm -rf {} \;
        else C=true;
        fi

        case $MODULE in
            k)
            if [ x$C == x"true" ];then clean_kernel; result=$?; fi
            if [ x$M == x"true" ];then
                build_kernel; result=$?
                #echo $result
                #if [ $result -eq 0 ];then make -j$CPUCORE bootimage-nodeps; result=$?; fi
            fi
            ;;

            lk)
            if [ x$C == x"true" ];then clean_lk; result=$?; fi
            if [ x$M == x"true" ];then build_lk; result=$?; fi
            ;;

            *)
            if [ x"$MODULE" == x"" ];then
                if [ x$C == x"true" ];then
                    echo "make clean"
                    make clean; result=$?;
                    #rm -rf $LOG_PATH/*;
                fi
                #echo "`date +"%F %T"`    ./quick_build.sh $1 $2 $3 $4 $5" >> $LOG_PATH/record.log
                if [ x$M == x"true" ];then
                    echo "make build project"
                    make -j$CPUCORE 2>&1 | tee $LOG_PATH/android.log; result=$?;
                fi
            else
                echo  -e "\033[31m !!!!!!   No Such module   !!!! \033[0m"
                exit 1
            fi
            ;;
        esac
        ;;

        mmma | mmm)
        $ACTION $MODULE 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;

        update-api | bootimage | systemimage | userdataimage | cacheimage | snod | bootimage-nodeps | userdataimage-nodeps | ramdisk-nodeps | otapackage | otadiff | cts | ptgen | apdimage | apdimage-nodeps)
        make -j$CPUCORE $ACTION 2>&1 | tee $LOG_PATH/android.log; result=$?
        ;;
    esac

    if [ $result -eq 0 ] && [ x$ACTION == x"mmma" -o x$ACTION == x"mmm" ];then
        echo "Start to release module ...."
        DIR=`echo $MODULE | sed -e 's/:.*//' -e 's:/$::'`
        NAME=${DIR##*/}
        TARGET=out/target/product/${PRODUCT}/obj/APPS/${NAME}_intermediates/package.apk
        if [ -f $TARGET ];then
            cp -f $TARGET /data/mine/test/MT6572/${MY_NAME}/${NAME}.apk
        fi
        TARGE_ODEX=out/target/product/${PRODUCT}/obj/APPS/${NAME}_intermediates/oat/${ARM}/package.odex
        if [ -f $TARGE_ODEX ];then
            cp -f $TARGE_ODEX /data/mine/test/MT6572/${MY_NAME}/${NAME}.odex
        fi
   fi
}

function Check_Space()
{
    UserHome=`pwd`
    Space=0
    Temp=`echo ${UserHome#*/}`
    Temp=`echo ${Temp%%/*}`
    ServerSpace=`df -lh $UserHome | grep "$Temp" | awk '{print $4}'`

    if echo $ServerSpace | grep -q 'G'; then
        Space=`echo ${ServerSpace%%G*}`
    elif echo $ServerSpace | grep -q 'T';then
        TSpace=1
    fi

    echo -e "\033[34m Log for Space $UserHome $ServerSpace $Space !!!\033[0m"
    if [ x"$TSpace" != x"1" ] ;then
        if [ "$Space" -le "30" ];then
            echo -e "\033[31m No Space!! Please Check!! \033[0m"
            exit 1
        fi
    fi
}

function build_boot_image(){
    echo "========== build BOOT.BF.3.3 =========="
    cd $amssPath/BOOT.BF.3.3/boot_images/build/ms/
    echo "start build boot_image"
    if [ x$CLEAN == x"c" ];then
        ./build.sh TARGET_FAMILY=8917 --prod -c
    else
        ./build.sh TARGET_FAMILY=8917 --prod 2>&1|tee $LOG_PATH/boot.log
        if [ "`grep "Successfully compile 8917" $LOG_PATH/boot.log`"  ];then
            echo -e "\033[40;32m Build BOOT.BF.3.3 Successfully \033[0m"
            sleep 2
        else
            echo -e "\033[40;31m Build BOOT.BF.3.3 failed (>.<) \033[0m"
            exit 1
        fi
    fi
}

function build_mpss(){
    echo "========== build MPSS.JO.3.0 =========="
    cd $amssPath/MPSS.JO.3.0
        echo -e "\033[40;32mCompile modem is $MODEM \033[0m"
        ./modem_clean.sh
        ./modem_compare.sh $MODEM
        cd $amssPath/MPSS.JO.3.0/modem_proc/build/ms
    echo "set environment"
    source setenv.sh
    echo "start build mpss"
    if [ x$CLEAN == x"c" ];then
        ./build.sh 8937.genns.prod -c
    else
        ./build.sh 8937.genns.prod -k 2>&1|tee $LOG_PATH/mpss.log
        if [ "`grep "Build 8937.genns.prod returned code 0" $LOG_PATH/mpss.log`"  ];then
            echo -e "\033[40;32m Build MPSS.JO.3.0 Successfully \033[0m"
            sleep 2
        else
            echo -e "\033[40;31m Build MPSS.JO.3.0 failed (>.<) \033[0m"
            exit 1
        fi
    fi
}

function build_rpm(){
    echo "========== build RPM.BF.2.2 =========="
    cd $amssPath/RPM.BF.2.2/rpm_proc/build
    source ./setenv.sh
    if [ x$CLEAN == x"c" ];then
        ./build_8917.sh -c
    else
        ./build_8917.sh 2>&1|tee $LOG_PATH/rpm_proc.log
        if [ "`grep "done building targets" $LOG_PATH/rpm_proc.log`" ];then
            echo -e "\033[40;32m Build RPM.BF.2.2 Successfully \033[0m"
            sleep 2
        else
            echo -e "\033[40;31m Build RPM.BF.2.2 failed (>.<) \033[0m"
            exit 1
        fi
    fi
}

function build_tz(){
    echo "========== build TZ.BF.4.0.5 =========="
    cd $amssPath/TZ.BF.4.0.5/trustzone_images/build/ms
    if [ x$CLEAN == x"c" ];then
        ./build.sh CHIPSET=msm8937 devcfg sampleapp -c
    else
        ./build.sh CHIPSET=msm8937 devcfg sampleapp 2>&1|tee $LOG_PATH/tz.log
        if [ "`grep "done building targets" $LOG_PATH/tz.log`" ];then
            echo -e "\033[40;32m Build TZ.BF.4.0.5 Successfully \033[0m"
            sleep 2
        else
            echo -e "\033[40;31m Build TZ.BF.4.0.5 failed (>.<) \033[0m"
            exit 1
        fi
    fi

}

function build_adsp(){
    echo "========== ADSP.8953.2.8.2 =========="
    cd $amssPath/ADSP.8953.2.8.2/adsp_proc
    source ./setenv.sh
    if [ x$CLEAN == x"c" ];then
        python ./build/build.py -c msm8937 -o clean
    else
        python ./build/build.py -c msm8937 -o all 2>&1|tee $LOG_PATH/adsp.log
        #./build/build.sh 2>&1|tee $LOG_PATH/adsp.log
        if [ "`grep "Compilation SUCCESS" $LOG_PATH/adsp.log`" ];then
            echo -e "\033[40;32m Build ADSP.8953.2.8.2 Successfully \033[0m"
            sleep 2
        else
            echo -e "\033[40;31m Build ADSP.8953.2.8.2 failed (>.<) \033[0m"
            exit 1
        fi
    fi
}
#guozishen@wind-mobi.com add start 20171229
function addGMS()
{
    GMS=$WsRootDir/../GMS_Z215_R8/gms-oem-NMR1-7.1-signed-r8-20171110/google

    if [ -d $GMS ];then
        echo "Remove old GMS"
        rm -fr vendor/google
        echo "Start to copy new GMS"
        cp -a $GMS vendor/
        echo "Complete copy new GMS"
    fi

}
#guozishen@wind-mobi.com end
#build common
function build_common(){
    echo "========== MSM8917.LA.3.0.1 =========="
    echo "make download files"
    if [ x$CLEAN != x"c" ];then
            cd $amssPath/MSM8917.LA.3.0/common/build
            python build.py $PRODUCT 2>&1|tee $LOG_PATH/common.log


        if [ "`grep "UPDATE COMMON INFO COMPLETE" $LOG_PATH/common.log`" ];then
                echo -e "\033[40;32m Build MSM8917.LA.3.0.1 Successfully \033[0m"
                sleep 2
            else
                echo -e "\033[40;31m Build MSM8917.LA.3.0.1 failed (>.<) \033[0m"
                exit 1

        fi
    fi
}

#release download files
function start_release(){
    cd $WsRootDir
    if [ -d "release_files" ];then
        rm -rf release_files
    fi
    mkdir release_files

    if [ x$RELEASE_PARAM != x"none" ] ; then
        if [ x$EFUSE == x"yes" ] ; then
          ./release_version.sh $CONFIG_NAME $RELEASE_PARAM efuse
        else
          ./release_version.sh $CONFIG_NAME $RELEASE_PARAM
        fi
    fi
}

function release_for_meizu(){

    if [ $MEIZU == true ] &&  [ x$CLEAN != x"c" ];then
        if [ ! -f vendor/amss/binary/$MODEM/rawprogram0.xml ] ;then
            echo -e "\033[40;31mCan't found vendor/amss/binary/$MODEM/rawprogram0.xml\033[0m"
            exit 1
        fi
        echo "Start make software for MEIZU... from vendor/amss/binary/$MODEM"
        cd $WsRootDir/vendor/amss/binary/$MODEM
        python $WsRootDir/tools/wind/scripts/checksparse.py -i rawprogram0.xml -s $WsRootDir/out/target/product/$PRODUCT/ -o rawprogram_unsparse.xml 2>&1|tee $LOG_PATH/mz_build.log
        cd $WsRootDir/out/target/product/$PRODUCT
        if [ -d "mz_build_files" ];then
            rm -rf mz_build_files
        fi
        mkdir mz_build_files
        cd mz_build_files
        mkdir sparse
        cp -r $WsRootDir/vendor/amss/binary/$MODEM/* sparse
        cp -r ../boot.img ../mdtp.img  ../recovery.img ../emmc_appsboot.mbn ../splash.img ../devinfomz.bin sparse

        mkdir unsparse
        cp -r sparse/* unsparse/
        cd unsparse/
        rm -rf system* userdata* cache* persist* rawprogram* gpt* patch0.xml custom*.img
        cp -r ../../system.img ../../custom.img ../../userdata.img ../../cache.img ../../persist.img ./
        cd  $WsRootDir/vendor/amss/binary/$MODEM
        git clean -df
        git checkout .
        cd  ..
        echo -e "\nSoftware build success!\n"
    fi
}

function cp_qcn_file(){

    qcn_file=$WsRootDir/vendor/amss/binary/wind_backup/$MODEM/fs_image.tar.gz.mbn.img
    OUT_PATH=$WsRootDir/out/target/product/$PRODUCT

    if  [ ! -f $qcn_file ] ;then
       echo -e "\033[40;31mCan't found $qcn_file\033[0m"
       exit 1
    fi
    if [ ! -d $OUT_PATH ] ;then mkdir  -p $OUT_PATH ; fi
    if [ x$RELEASE_PARAM != x"none" ] ; then echo "start cp $qcn_file to $OUT_PATH"; fi
    cp  $qcn_file  $OUT_PATH
}

function main(){
    ##################################################################
    #Check parameters
    ##################################################################
    command_array=($1 $2 $3 $4 $5)
    if [ ! -d $LOG_PATH ];then
        mkdir $LOG_PATH
    fi

    echo "`date +"%F %T"`    ./quick_build.sh $1 $2 $3 $4 $5" >> $LOG_PATH/record.log
    for command in ${command_array[*]}; do

        ### set PRODUCT
        case $command in
        msm8937_64)
            if [ x$PRODUCT != x"" ];then continue; fi
            PRODUCT=msm8937_64
            RELEASEPATH=msm8937_64
            ADDGMS=false
            ARM=arm64
            CONFIG_NAME=$command
            continue
            ;;
        Z215|M1810M)
            if [ x$PRODUCT != x"" ];then continue; fi
            if [ x$command = x"M1810M" ]; then MEIZU=true; fi
            PRODUCT=msm8937_64
            RELEASEPATH=msm8937_64
            #guozishen@wind-mobi.com add start 20171229
            ADDGMS=true
            #guozishen@wind-mobi.com end
            ARM=arm64
            CONFIG_NAME=Z215
            MODEM=Z215
            export CHINAMOBILE_CUSTOMIZE=true
            continue
            ;;
        Z216|M1810)
            if [ x$PRODUCT != x"" ];then continue; fi
            if [ x$command = x"M1810" ]; then MEIZU=true; fi
            PRODUCT=msm8937_64
            RELEASEPATH=msm8937_64
            ADDGMS=false
            ARM=arm64
            CONFIG_NAME=Z216
            MODEM=Z216
            export MZ_INTERNATIONAL=intl
            continue
            ;;
        esac


        ### set VARIANT
        if [ x$command == x"user" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=user
        elif [ x$command == x"debug" ] || [ x$command == x"userdebug" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=userdebug
        elif [ x$command == x"eng" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=eng
        elif [ x$command == x"qfil" ] ;then
            BUILD_MODE=all
            RELEASE_PARAM=qfil
            ACTION=new
        elif [ x$command == x"factory" ] ;then
            BUILD_MODE=all
            RELEASE_PARAM=factory
            ACTION=new
            #qidongdong@wind-mobi.com on 2017.12.15 start
            #add for factory build close selinux
            export TARGET_BUILD_WIND_CLOSE_SELINUX=true
            #qidongdong@wind-mobi.com on 2017.12.15 end
            #gaozhixiang@wind-mobi.com 20180105 start for factory FFBM
            export TARGET_BUILD_WIND_QFIL=true
            #gaozhixiang@wind-mobi.com 20180105 end for factory FFBM
        elif [ x$command == x"all" ] ;then
            BUILD_MODE=$command
            RELEASE_PARAM=all
        elif [ x$command == x"amss" ] || [ x$command == x"boot" ] || [ x$command == x"mpss" ] || [ x$command == x"rpm_proc" ] || [ x$command == x"tz" ] || [ x$command == x"adsp" ] || [ x$command == x"common" ] ;then
            BUILD_MODE=$command
            RELEASE_PARAM=amss

        ### set ACTION
        elif [ x$command == x"r" ] || [ x$command == x"remake" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=remake
            if [ x$RELEASE_PARAM == x"none" ];then RELEASE_PARAM=ap; fi
        elif [ x$command == x"n" ] || [ x$command == x"new" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=new
            if [ x$RELEASE_PARAM == x"none" ];then RELEASE_PARAM=ap; fi
        elif [ x$command == x"c" ] || [ x$command == x"clean" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=clean
            CLEAN=c
            RELEASE_PARAM=none
        elif [ x$command == x"revert" ] ;then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=revert
            RELEASE_PARAM=none
        elif [ x$command == x"mmma" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmma
            RELEASE_PARAM=none
        elif [ x$command == x"mmm" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmm
            RELEASE_PARAM=none
        elif [ x$command == x"bootimage" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage
            RELEASE_PARAM=boot
        elif [ x$command == x"system" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=systemimage
            RELEASE_PARAM=system
        elif [ x$command == x"userdata" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage
            RELEASE_PARAM=userdata
        elif [ x$command == x"boot-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage-nodeps
            RELEASE_PARAM=boot
        elif [ x$command == x"snod" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=snod
            RELEASE_PARAM=system
        elif [ x$command == x"userdata-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage-nodeps
            RELEASE_PARAM=userdata
        elif [ x$command == x"ramdisk-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=ramdisk-nodeps
            RELEASE_PARAM=boot
        elif [ x$command == x"recovery" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=recoveryimage
            RELEASE_PARAM=recovery
        elif [ x$command == x"cache" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=cacheimage
            RELEASE_PARAM=none
        elif [ x$command == x"otapackage" ] || [ x$command == x"ota" ] ;then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otapackage
            RELEASE_PARAM=none
        ### set ORIGINAL
        elif [ x$command == x"o" ];then
            if [ x$ORIGINAL != x"" ];then continue; fi
            ORIGINAL=no
        elif [ x$command == x"k" ] || [ x$command == x"kernel" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=k
            RELEASE_PARAM=boot
        elif [ x$command == x"lk" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=lk
            RELEASE_PARAM=aboot
        elif [ x$command == x"cse" ];then
            #qidongdong@wind-mobi.com on 2017.12.15 start
            #add for factory build close selinux
            export TARGET_BUILD_WIND_CLOSE_SELINUX=true
            #qidongdong@wind-mobi.com on 2017.12.15 end
            #gaozhixiang@wind-mobi.com 20180105 start for factory FFBM
            export TARGET_BUILD_WIND_QFIL=true
            #gaozhixiang@wind-mobi.com 20180105 end for factory FFBM
        elif [ x$command == x"efuse" ] || [ x$command == x"sign" ] ;then
            export MEIZU_MTK_LOCK=true
            EFUSE=yes
        else
            if [ x$MODULE != x"" ];then continue; fi
            if [ x$command != x"all" ] && [ x$command != x"android" ] && [ x$command != x"amss" ] && [ x$command != x"boot" ] && [ x$command != x"mpss" ] && [ x$command != x"rpm_proc" ] && [ x$command != x"tz" ] && [ x$command != x"adsp" ] && [ x$command != x"common" ];then
            MODULE=$command
            fi
        fi
    done

    if [ x"$ACTION" == x"revert" ];then
      revert_code
    else
      echo "********This build project PRODUCT is $PRODUCT********"
      #echo "PRODUCT=$PRODUCT VARIANT=$VARIANT ACTION=$ACTION"
      echo "Log Path $LOG_PATH"
    fi
    if [ x$EFUSE == x"yes" ];then
      cd $WsRootDir
      cp -a efusekey/* vendor/qcom/proprietary/common/scripts/SecImagewind/resources/data_prov_assets/Signing/Local/mz_presigned_certs-key2048_exp65537/
      cp -a efusekey/* amss/MSM8917.LA.3.0/common/sectools/resources/data_prov_assets/Signing/Local/mz_presigned_certs-key2048_exp65537/
    fi
    
    for command in ${command_array[*]}
    do
        if [ x$command == x"all" ] || [ x$command == x"qfil" ] || [ x$command == x"factory" ];then
            echo "build all moudles"
            if [ x$MEIZU != x"true" ];then
                build_boot_image
                build_mpss
                build_rpm
                build_tz
                build_adsp
                if [ x$EFUSE == x"yes" ];then
                  build_efuse
                fi
                build_android
                echo -e "\033[40;32m All moudles build finished \033[0m"
                build_common
            fi
        elif [ x$command == x"amss" ];then
            echo "build all in amss"
            build_boot_image
            build_mpss
            build_rpm
            build_tz
            build_adsp
            if [ x$EFUSE == x"yes" ];then
              build_efuse
            fi
            echo -e "\033[40;32mmoudles in amss build finished \033[0m"
            if [ -d "$WsRootDir/out/target/product/$PRODUCT" ];then
              build_common
            fi
        elif [ x$command == x"sign" ];then
            echo "sign image after build all"
            if [ x$EFUSE == x"yes" ];then
              build_efuse
            fi
            if [ -d "$WsRootDir/out/target/product/$PRODUCT" ];then
              build_common
            fi
        fi
    done

    for command in ${command_array[*]}
    do
        case $command in
            boot)
            build_boot_image
            ;;
            mpss)
            build_mpss
            ;;
            rpm_proc)
            build_rpm
            ;;
            tz)
            build_tz
            ;;
            adsp)
            build_adsp
            ;;
            common)
            build_common
            ;;
        esac
    done

    cd $WsRootDir
    if [ x$MEIZU == x"true" ];then
        if [ x$PRODUCT == x"" ];then
          PRODUCT=msm8937_64
          RELEASEPATH=msm8937_64
          ADDGMS=false
          ARM=arm64
          CONFIG_NAME=msm8937_64
        fi
        echo "start build android"
        build_android
        echo "start release_for_meizu"
        release_for_meizu
    else
        if [ x"$BUILD_MODE" == x"" ] && [ x"$ACTION" != x"" ] && [ x"$ACTION" != x"revert" ];then
            echo "build_android"
            build_android
        fi
        cp_qcn_file

        if [ x$CLEAN != x"c" ]; then
            start_release
        fi
    fi

    cd $WsRootDir/prebuilts/sdk/tools
    ./jack-admin kill-server
    cd - > /dev/null
}

function start_make() {
    local start_time=$(date +"%s")
    main $@
    local ret=$?
    local end_time=$(date +"%s")
    local tdiff=$(($end_time-$start_time))
    local hours=$(($tdiff / 3600 ))
    local mins=$((($tdiff % 3600) / 60))
    local secs=$(($tdiff % 60))
    local ncolors=$(tput colors 2>/dev/null)
        if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
             color_failed=$'\E'"[0;31m"
             color_success=$'\E'"[0;32m"
             color_reset=$'\E'"[00m"
        else
             color_failed=""
             color_success=""
             color_reset=""
        fi
        echo
       if [ $ret -eq 0 ] ; then
            echo -n "${color_success}#### make completed successfully "
       else
            echo -n "${color_failed}#### make failed to build some targets "
       fi

       if [ $hours -gt 0 ] ; then
           printf "(%02g:%02g:%02g (hh:mm:ss))" $hours $mins $secs
       elif [ $mins -gt 0 ] ; then
           printf "(%02g:%02g (mm:ss))" $mins $secs
       elif [ $secs -gt 0 ] ; then
            printf "(%s seconds)" $secs
       fi
        echo " ####${color_reset}"
        echo
}

start_make $1 $2 $3 $4 $5 2>&1|tee $LOG_PATH/build.log
