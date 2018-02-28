#!/bin/bash

#################################################################################################################################
### 目前此代码主要用于Z216项目，因此 release时 项目名称可以省略，如键入：./release_vesrion.sh

######  ./release_version.sh  Z215/Z216                                    释放fastboot下载的 amss+ap (amss_debug+vmlinx)
######  ./release_version.sh  Z215/Z216  qfil                            释放Qfil下载(正常版本)的 amss+ap (amss_debug+vmlinx)
######  ./release_version.sh  Z215/Z216  factory                         释放工厂版本的 amss+ap (amss_debug+vmlinx)
######  ./release_version.sh  Z215/Z216  ap                              仅释放fastboot下载的ap imag (vmlinux)
######   ./release_version.sh Z215/Z216  amss                               all amss  images  (amss_debug)
######   ./release_version.sh Z215/Z216  boot                               boot.img           (vmlinux)
######   ./release_version.sh Z215/Z216  system                             system.img
######   ./release_version.sh Z215/Z216  system-                            ap images except system.img
######   ./release_version.sh Z215/Z216  aboot                              emmc_appsboot.mbn
######   ./release_version.sh Z215/Z216  recovery                           recovery.img
######   ./release_version.sh Z215/Z216  userdata                           userdata.img
#################################################################################################################################




rootDir=`pwd`
user=`whoami`
PRODUUCT_NAME=
AMSS_PATH=amss
CHIPID_DIR=MSM8917.LA.3.0
IS_AMSS_DEBUG_RELEASE=no
IS_VMLINUX_RELEASE=no
release_param=
SPARSE_IMAGE_PATH=amss/MSM8917.LA.3.0/common/build/bin/asic/sparse_images
RELEASE_FILE=
EFUSE=
SEC_PATH=

command_array=($1 $2 $3 $4 $5 $6)

function echo_greeen(){
echo -e "\033[40;32m$1 \033[0m"
}

function echo_red(){
echo -e "\033[40;31m$1 \033[0m"
}

function get_amss_debug(){

    amss_debug=amss_debug

    contents_path=$AMSS_PATH/$CHIPID_DIR/contents.xml
    mkdir -p release_files/$amss_debug/META
    cp $contents_path release_files/$amss_debug/META/
    
    debug_path=release_files/$amss_debug
    
    amss_arrays=(
        $AMSS_PATH/ADSP.8953.2.8.2/adsp_proc/build/ms/*.elf
        $AMSS_PATH/ADSP.8953.2.8.2/adsp_proc/qdsp6/qshrink/src/msg_hash.txt
        $AMSS_PATH/MPSS.JO.3.0/modem_proc/build/ms/*.elf
        $AMSS_PATH/RPM.BF.2.2/rpm_proc/core/bsp/rpm/build/8917/RPM_AAAAANAAR.elf
        $AMSS_PATH/TZ.BF.4.0.5/trustzone_images/core/securemsm/trustzone/qsee/qsee.elf
        $AMSS_PATH/MPSS.JO.3.0/modem_proc/build/myps/qshrink/*
    )   

    for file in ${amss_arrays[*]} ;do
        if [ -f  $file ] ;then
            t_path=${file#*/}
            t0_path=${t_path#*/}
            t1_path=${t0_path%/*}
            file_path=$debug_path/$t1_path
            if [ ! -d  $file_path ];then
                mkdir  -p  $file_path
            fi
            echo $file
            cp  -a $file  $file_path
        else
            echo_red "release error: can't found $file"
            #exit 1
        fi
    
    done


    wlan_ko_file=$OUT_PATH/obj/vendor/qcom/opensource/wlan/prima/pronto_wlan.ko
    if [ -f $wlan_ko_file ] ;then
        echo $wlan_ko_file
        mkdir -p release_files/$amss_debug/out_obj/vendor/qcom/opensource/wlan/prima/
        cp $wlan_ko_file release_files/$amss_debug/out_obj/vendor/qcom/opensource/wlan/prima/
    else
            if [ x$IS_VMLINUX_RELEASE == x"yes" ] ;then
                echo_red "release error: can't found $file"
                #exit 1
            fi
    fi

    cd release_files
    zip amss_debug.zip amss_debug/ -r
    rm -rf amss_debug/
    cd ..
}

function get_vmlinux(){

vmlinux_file=$OUT_PATH/obj/KERNEL_OBJ/vmlinux
if [ -f $vmlinux_file ];then
    zip -rqj ${vmlinux_file}.zip  $vmlinux_file ; result=$?
    if [ $result -eq 0 ] ;then
        echo ${vmlinux_file}.zip
        cp ${vmlinux_file}.zip  release_files/
    fi
fi

}

function echo_systemSize() {
    
    if [ -f release_files/system.img ] && [ -f $OUT_PATH/system.img ] ;then
        system_size=`ls -l --block-size=k  $OUT_PATH/system.img | awk '{print $5}'`
        echo_greeen "system.img ---- ${system_size}B"
    fi
}



for arg in ${command_array[*]}
do
        case $arg in
           Z215|Z216)
              PROJECT_NAME=$arg
              PRODUUCT_NAME=msm8937_64
              ;;
           dbg|debug)
              IS_AMSS_DEBUG_RELEASE=yes
              IS_VMLINUX_RELEASE=yes
              ;;
            qfil|Qfil|factory|fac)
               release_param="qfil"
              ;;
            amss|ap|boot|system|system-|aboot|recovery|userdata)
                release_param=$arg
              ;;
           EFUSE|efuse)
              EFUSE=yes
              ;;
        esac
done



if [ x$PROJECT_NAME == x"" ];then
    PROJECT_NAME=Z216
    PRODUUCT_NAME=msm8937_64
    echo -e "\033[35mYou haven't input any project name, so start relase as default product:$PRODUUCT_NAME\033[0m"
fi


if [ x$release_param == x"" ];then
    release_param=all
fi


OUT_PATH=out/target/product/$PRODUUCT_NAME

if [ x$EFUSE == x"yes" ];then
  SEC_PATH=$AMSS_PATH/MSM8917.LA.3.0/common/sectools/fuseblower_output/v2
else
  SEC_PATH=$AMSS_PATH/MSM8917.LA.3.0/common/sectools/resources/build/fileversion2
fi

amss_arrays=(
    $AMSS_PATH/BOOT.BF.3.3/boot_images/build/ms/bin/LAASANAZ/sbl1.mbn
    $AMSS_PATH/BOOT.BF.3.3/boot_images/build/ms/bin/LAADANAZ/prog_emmc_firehose_8917_ddr.mbn
    $AMSS_PATH/TZ.BF.4.0.5/trustzone_images/build/ms/bin/ZALAANAA/tz.mbn
    $AMSS_PATH/TZ.BF.4.0.5/trustzone_images/build/ms/bin/ZALAANAA/devcfg.mbn
    $AMSS_PATH/TZ.BF.4.0.5/trustzone_images/build/ms/bin/ZALAANAA/keymaster.mbn
    $AMSS_PATH/TZ.BF.4.0.5/trustzone_images/build/ms/bin/ZALAANAA/cmnlib.mbn
    $AMSS_PATH/TZ.BF.4.0.5/trustzone_images/build/ms/bin/ZALAANAA/cmnlib64.mbn
    $AMSS_PATH/RPM.BF.2.2/rpm_proc/build/ms/bin/8917/rpm.mbn
    $AMSS_PATH/MSM8917.LA.3.0/common/build/bin/asic/NON-HLOS.bin
    $AMSS_PATH/MSM8917.LA.3.0/common/build/gpt_main0.bin
    $SEC_PATH/sec.dat
    $AMSS_PATH/MSM8917.LA.3.0/common/build/gpt_backup0.bin
    $AMSS_PATH/MSM8917.LA.3.0/common/build/patch0.xml
    $AMSS_PATH/MSM8917.LA.3.0/common/build/rawprogram0.xml
    $AMSS_PATH/ADSP.8953.2.8.2/adsp_proc/build/dynamic_signed/8937/adspso.bin
    $AMSS_PATH/ADSP.8953.2.8.2/adsp_proc/build/ms/bin/AAAAAAAA/dsp2.mbn
    $OUT_PATH/fs_image.tar.gz.mbn.img
)

qfil_ap_arrays=(
    $OUT_PATH/emmc_appsboot.mbn
    $OUT_PATH/boot.img
    #chenshu@wind-mobi.com 2017.12.11 start#
    $OUT_PATH/splash.img
    #chenshu@wind-mobi.com 2017.12.11 end#
    $OUT_PATH/recovery.img
    $OUT_PATH/mdtp.img
    $OUT_PATH/devinfomz.bin
)

ap_arrays=(
    $OUT_PATH/emmc_appsboot.mbn
    $OUT_PATH/boot.img
    #chenshu@wind-mobi.com 2017.12.11 start#
    $OUT_PATH/splash.img
    #chenshu@wind-mobi.com 2017.12.11 end#
    $OUT_PATH/system.img
    $OUT_PATH/userdata.img
    $OUT_PATH/recovery.img
    $OUT_PATH/cache.img
    $OUT_PATH/mdtp.img
    $OUT_PATH/persist.img
    $OUT_PATH/custom.img
    $OUT_PATH/devinfomz.bin
)

ap_arrays_ex_system=(
    $OUT_PATH/emmc_appsboot.mbn
    $OUT_PATH/boot.img
    #chenshu@wind-mobi.com 2017.12.11 start#
    $OUT_PATH/splash.img
    #chenshu@wind-mobi.com 2017.12.11 end#
    $OUT_PATH/userdata.img
    $OUT_PATH/recovery.img
    $OUT_PATH/cache.img
    $OUT_PATH/mdtp.img
    $OUT_PATH/persist.img
    $OUT_PATH/custom.img
    $OUT_PATH/devinfomz.bin
)

  case $release_param in
        all)
            file_arrays=(${amss_arrays[@]} ${ap_arrays[@]})
            IS_AMSS_DEBUG_RELEASE=yes
            IS_VMLINUX_RELEASE=yes
            ;;
        qfil)
            file_arrays=(${amss_arrays[@]} ${qfil_ap_arrays[@]})
            IS_AMSS_DEBUG_RELEASE=yes
            IS_VMLINUX_RELEASE=yes
            ;;
        amss)
            file_arrays=(${amss_arrays[@]})
            IS_AMSS_DEBUG_RELEASE=yes
            ;;
        ap)
            file_arrays=(${ap_arrays[@]})
            IS_VMLINUX_RELEASE=yes
            ;;
        system-)
            file_arrays=(${ap_arrays_ex_system[@]})
            ;;
        system)
            RELEASE_FILE="system.img"
            ;;
        boot)
            RELEASE_FILE="boot.img"
            IS_VMLINUX_RELEASE=yes
            ;;
        aboot)
            RELEASE_FILE="emmc_appsboot.mbn"
            ;;
        recovery)
            RELEASE_FILE="recovery.img"
            ;;
        userdata)
            RELEASE_FILE="userdata.img"
            ;;
    esac


echo -e "\033[33mPRODUCT=$PRODUUCT_NAME  release_param=$release_param IS_AMSS_DEBUG_RELEASE=$IS_AMSS_DEBUG_RELEASE IS_VMLINUX_RELEASE=$IS_VMLINUX_RELEASE EFUSE=$EFUSE\033[0m"
echo


if [ -d "release_files" ];then
    rm -rf release_files
fi
mkdir release_files
sleep 1



if [ x$RELEASE_FILE != x"" ] ;then
    all_file_arrays=(${ap_arrays[@]} ${amss_arrays[@]})

    for file in ${all_file_arrays[*]}
    do
        if [[ $file = *${RELEASE_FILE} ]] ; then
            if [ -f "$file" ];then
                echo "Just release $file"
                cp $file release_files/
                break
            else
                echo_red "release error: can't found"
            fi
        fi
    done
else
    for file in ${file_arrays[*]}
    do
        if [ -f "$file" ];then
            echo $file
            cp $file release_files/
        else
            echo_red "release error: can't found $file"
            if [ x$release_param == x"qfil" ]; then
	       exit 1
            fi
        fi
    done
fi

if [ x$release_param == x"qfil" ]; then
    ls -1 $SPARSE_IMAGE_PATH/*
    cp  -a  $SPARSE_IMAGE_PATH/*   release_files/
    sleep 1
    if [ -f release_files/rawprogram_unsparse.xml ] ;then
        rm -rf  release_files/rawprogram0.xml
    else
        echo_red "Copy rawprogram_unsparse.xml error!!!"
        exit 1
    fi
    relase_time=`date +%y%m%d`
    QFIL_VERSION=${PROJECT_NAME}_QFIL_VERSION_$relase_time
    rm -rf $QFIL_VERSION
    mv release_files  $QFIL_VERSION
    mkdir release_files
    echo
    echo -e "\033[35mPacked for $QFIL_VERSION, please wait a few minutes....\033[0m"
    zip -rq  $QFIL_VERSION.zip $QFIL_VERSION
    mv  ${QFIL_VERSION}.zip   release_files/
    rm -rf $QFIL_VERSION
    filesize=`ls -l --block-size=k release_files/${QFIL_VERSION}.zip | awk '{print $5}'`
    echo_greeen "$QFIL_VERSION.zip ---- ${filesize}B"
fi


#是否需要debug文件
if [ "yes" == $IS_AMSS_DEBUG_RELEASE ];then
    get_amss_debug
fi


if [ "yes" == $IS_VMLINUX_RELEASE ];then
    get_vmlinux
fi



cd release_files

if [ ! -f "checklist.md5" ]; then
    echo "/*" >> checklist.md5
    echo "* wind-mobi md5sum checklist" >> checklist.md5
    echo "*/" >> checklist.md5
fi

checklist="./checklist.md5"

for file in ./*;
do
    if [ x"$file" != x"$checklist" ];then
        md5=`md5sum -b $file`
        line=`grep -n "$file" checklist.md5 | cut -d ":" -f 1`
        if [ x"$line" != x"" ]; then
           sed -i $line's/.*/'"$md5"'/' checklist.md5
        else
           if [ x"$md5" != x"" ];then
           echo "$md5" >> checklist.md5
           fi
        fi
    fi
done

sed -i 's/'"\*\.\/"'/\*/' checklist.md5

cd ..

echo
echo_greeen "Start release files..."
echo "cp -a release_files/* /data/mine/test/MT6572/$user/"

cp  -a   release_files/* /data/mine/test/MT6572/$user/; result=$?

echo_systemSize

if [ $result -eq 0 ] ; then
    echo_greeen "Release files success!!!"
else 
    echo_red "Cp failed!!!"
fi
