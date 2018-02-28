#!/bin/bash
build_param=$1
release_param=$2

if [ x"$build_param" = "x" ];then
    echo "Usage: command [build_param]. e.g. command l300"
    return 1
fi

if [ x"$release_param" = "x" ];then
   release_param=all
fi

ROOT=`pwd`
OUT_PATH=$ROOT"/out/target/product"
MY_NAME=`whoami`
HARDWARE_VER=S01
PLATFORM=MT6737T

case $build_param in
    gr6737t_65_l_n)
        HARDWARE_VER=S01
        OUT_PATH=$OUT_PATH/gr6737t_65_le_n
        build_param=gr6737t_65_le_n
        PLATFORM=MT6737T
        ;;
    A158)
        HARDWARE_VER=S01
        OUT_PATH=$OUT_PATH/A158
        build_param=A158
        PLATFORM=MT6737M
        ;;
    *)
        echo "no such project!!"
        exit 1
        ;;
esac

if [ ! -d $OUT_PATH ];then
    echo "ERROR: there is no out path:$OUT_PATH"
    return
fi

if [ x"$release_param" = x"all" ] ||  [ x"$release_param" == x"sign" ]; then
    for i in "$OUT_PATH/system/vendor/etc/mddb/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_ltg_n" ; do
        if [ -f $i ]; then
            cp $i  $OUT_PATH/Modem_Database_ltg
        fi
    done
    for i in "$OUT_PATH/system/vendor/etc/mddb/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_lwg_n" ; do
        if [ -f $i ]; then
            cp $i  $OUT_PATH/Modem_Database_lwg
        fi
    done
    for i in "$OUT_PATH/obj/CGEN/APDB_MT6735_"$HARDWARE_VER"_alps-mp-n0.mp1_W18.??" ; do
        if [ -f $i ]; then
            cp $i $OUT_PATH/AP_Database
        fi
    done
fi

if [ ! -f $OUT_PATH/Modem_Database_ltg ];then
    ALL_RELEASE_FILES="logo.bin $PLATFORM"_Android_scatter.txt" preloader_$1.bin AP_Database Modem_Database_lwg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
elif [ ! -f $OUT_PATH/Modem_Database_lwg ];then
    ALL_RELEASE_FILES="logo.bin $PLATFORM"_Android_scatter.txt" preloader_$1.bin AP_Database Modem_Database_ltg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
else
    ALL_RELEASE_FILES="logo.bin $PLATFORM"_Android_scatter.txt" preloader_$1.bin AP_Database Modem_Database_ltg Modem_Database_lwg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
fi
    SIGN_RELEASE_FILES="$PLATFORM"_Android_scatter.txt" preloader_$1.bin  AP_Database Modem_Database_lwg boot-sign.img cache-sign.img lk-sign.bin logo-sign.bin recovery-sign.img secro-sign.img system-sign.img trustzone-sign.bin userdata-sign.img"
case $release_param in
    all)
        RELEASE_FILES=$ALL_RELEASE_FILES
        ;;
    system)
        RELEASE_FILES="system.img"
        ;;
    recovery)
        RELEASE_FILES="recovery.img"
        ;;
    boot)
        RELEASE_FILES="boot.img"
        ;;
    lk)
        RELEASE_FILES="lk.bin"
        ;;
    logo)
        RELEASE_FILES="logo.bin"
        ;;
    userdata)
        RELEASE_FILES="userdata.img"
        ;;
    pl)
        RELEASE_FILES="preloader_$1.bin"
        ;;
    sign)
        RELEASE_FILES=$SIGN_RELEASE_FILES
        ;;
    ota)
        cd $OUT_PATH
        ota_files=`ls -dt full_${build_param}-ota-*.zip | head -n 1`

        if [ -d $OUT_PATH/obj/PACKAGING/target_files_intermediates ]; then
            cd $OUT_PATH/obj/PACKAGING/target_files_intermediates
            target_files=`ls -dt full_${build_param}-target_files-*.zip | head -n 1`
        fi
		
        if [ -f $OUT_PATH/obj/KERNEL_OBJ/vmlinux ]; then
        {
            cd $OUT_PATH/obj/KERNEL_OBJ
            if [ -f ./vmlinux.zip ]; then
            rm -rf vmlinux.zip
            fi
            zip -rq vmlinux.zip vmlinux
            mv $OUT_PATH/obj/KERNEL_OBJ/vmlinux.zip $OUT_PATH
            vmlinux_files=vmlinux.zip
        }
        fi
        if [ -d $OUT_PATH/symbols ]; then
        {
            cd $OUT_PATH
            if [ -f ./symbols.zip ]; then
            rm -rf symbols.zip
            fi
            zip -rq symbols.zip symbols
            symbols_files=symbols.zip
        }
        fi
        cd $ROOT
        
        RELEASE_FILES="$target_files $ota_files $vmlinux_files $symbols_files"
        ;;
     #chusuxia@wind-mobi.com 20161206 add for build verify ota start
    otav)
        cd $OUT_PATH
        otav_files=`ls -dt full_${build_param}-verifyota-*.zip | head -n 1`
        cd $ROOT
        RELEASE_FILES="$otav_files"
        ;;
    #chusuxia@wind-mobi.com 20161206 add for build verify ota end
    diff)
        if [ -f ./updateA2B.zip ] &&  [ -f ./updateB2C.zip ] ; then
            diff_files="updateA2B.zip updateB2C.zip"
        elif  [ -f ./updateA2B.zip ]; then
            diff_files=updateA2B.zip
        elif  [ -f ./updateB2C.zip ]; then
            diff_files=updateB2C.zip
        fi
        RELEASE_FILES="$diff_files"
        ;;
    none)
        ;;		
    *)
        echo "not supported!!"
        exit 1
        ;;
esac

FILES=""
for file in $RELEASE_FILES; do
    if [ x"$file" == x"system.img" ] ;then
        filesize=`ls -l --block-size=k $OUT_PATH/$file | awk '{print $5}'`
        echo "$file ---- ${filesize}B"
    elif [ x"$file" == x"system-sign.img" ] ;then  
        filesize=`ls -l --block-size=k $OUT_PATH/signed_bin/$file | awk '{print $5}'`
        echo "$file ---- ${filesize}B"  
    elif [ x"$target_files" != x"" ] && [ x"$file" == x"$target_files" ] ;then
        filesize=`ls -l --block-size=k $OUT_PATH/obj/PACKAGING/target_files_intermediates/$file | awk '{print $5}'`
        echo "$file ---- ${filesize}B"    
    elif [ x"$ota_files" != x"" ] && [ x"$file" == x"$ota_files" ] ;then
        filesize=`ls -l --block-size=k $OUT_PATH/$file | awk '{print $5}'`
        echo "$file ---- ${filesize}B"
    elif [ x"$vmlinux_files" != x"" ] && [ x"$file" == x"$vmlinux_files" ] ;then
        filesize=`ls -l --block-size=k $OUT_PATH/$file | awk '{print $5}'`
        echo "$file ---- ${filesize}B"
    elif [ x"$symbols_files" != x"" ] && [ x"$file" == x"$symbols_files" ] ;then
        filesize=`ls -l --block-size=k $OUT_PATH/$file | awk '{print $5}'`
        echo "$file ---- ${filesize}B"
    else
        echo "$file"
    fi
    if [ x"$target_files" != x"" ] && [ x"$file" == x"$target_files" ] ;then
        FILES=$FILES" "$OUT_PATH"/obj/PACKAGING/target_files_intermediates/"$file
    elif [ x"$file" == x"updateA2B.zip" ] || [ x"$file" == x"updateB2C.zip" ] ;then
        FILES=$FILES" "$ROOT"/"$file
    elif [[ $file = *sign* ]]; then
        FILES=$FILES" "$OUT_PATH"/signed_bin/"$file
    else
        FILES=$FILES" "$OUT_PATH"/"$file
    fi
done

if [ x"$RELEASE_FILES" != x"" ]; then
    if [ ! -f "$OUT_PATH/checklist.md5" ]; then
        echo "/*" >> $OUT_PATH/checklist.md5
        echo "* wind-mobi md5sum checklist" >> $OUT_PATH/checklist.md5
        echo "*/" >> $OUT_PATH/checklist.md5
    fi
    for file in $RELEASE_FILES; do
        if [ x"$target_files" != x"" ] && [ x"$file" == x"$target_files" ]; then
            cd $OUT_PATH/obj/PACKAGING/target_files_intermediates
        elif [ x"$file" == x"updateA2B.zip" ] || [ x"$file" == x"updateB2C.zip" ] ;then
            cd $ROOT
        elif [[ $file = *sign* ]];then
            cd $OUT_PATH/signed_bin/
        else
            cd $OUT_PATH
        fi
        md5=`md5sum -b $file`
        if [ -f "$OUT_PATH/checklist.md5" ]; then
            if [ x"$target_files" != x"" ] && [ x"$file" == x"$target_files" ] ;then
                line=`grep -n "\-target_files-" $OUT_PATH/checklist.md5 | cut -d ":" -f 1`
            elif [ x"$ota_files" != x"" ] && [ x"$file" == x"$ota_files" ] ;then
                line=`grep -n "\-ota-" $OUT_PATH/checklist.md5 | cut -d ":" -f 1`
            else
                line=`grep -n "$file" $OUT_PATH/checklist.md5 | cut -d ":" -f 1`
            fi
        fi
        if [ x"$line" != x"" ]; then
            sed -i $line's/.*/'"$md5"'/' $OUT_PATH/checklist.md5
        else
            if [ x"$md5" != x"" ];then 
            echo "$md5" >> $OUT_PATH/checklist.md5
            fi
        fi
    done
    cd $ROOT
    if [ -f "$OUT_PATH/checklist.md5" ]; then
        FILES=$FILES" "$OUT_PATH"/"checklist.md5
    fi
fi

cp $FILES /data/mine/test/MT6572/$MY_NAME/

echo "Sucess!"
