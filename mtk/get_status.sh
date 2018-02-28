#!/bin/bash

WsRootDir=`pwd`
CODEPATH=$1
WINDPATH=$WsRootDir/wind/custom_files
FLAG=0
FLAG_ADD=0
FLAG_MODIFY=0
FLAG_DISPLAY=0

function git_st()
{
    TMPPATCH=$WsRootDir/$CODEPATH/

    while read line
    do
        if [ "`echo $line | grep -rsn 'modified'`" ];then
            if [ -e $WINDPATH/$CODEPATH/${line:14} ] ; then
                add_to_modify_line ${line:14}
            else
                add ${line:14}
            fi
        fi
        
        if [ "`echo $line | grep -rsn '(use "git add <file>..." to include in what will be committed)'`" ];then
	        FLAG=1
	        continue
        fi
        if [ "`echo $line | grep -rsn 'no changes added to commit (use "git add" and/or "git commit -a")'`" ];then
	        FLAG=0
	        continue
        fi

        if [ "`echo $line | grep -rsn 'nothing added to commit but untracked files present'`" ];then
	        FLAG=0
	        continue
        fi
        
        if [ $FLAG == 1 ] && [ x"$line" != x"#" ];then
            if [ -e $WINDPATH/$CODEPATH/${line:2} ] ; then
                add_to_modify_line ${line:2}
            else
                add ${line:2}
            fi
        fi

    done < $WsRootDir/.st_tmp
}

function compare_folder()
{
    cd $WsRootDir/$CODEPATH
    CodePathFiles=`find ./$1 ! -type d`
    cd $WsRootDir/
    for codepathfile in $CodePathFiles;do
        if [ -e $WINDPATH/$CODEPATH/$codepathfile ] ; then
            CMP_TMP=`cmp $WsRootDir/$CODEPATH/$codepathfile $WINDPATH/$CODEPATH/$codepathfile`
            if [ x"$CMP_TMP" != x"" ];then
                modify ${codepathfile:2}
            fi
        else
            add ${codepathfile:2}
        fi
    done
    
}

function modify()
{
    if [ ! -e $WsRootDir/.modify_st_tmp ] ; then
        cp $WsRootDir/wind/scripts/.modify_st_tmp $WsRootDir
    fi

    sed -i "/modified end/i\\$1" $WsRootDir/.modify_st_tmp
    FLAG_MODIFY=1
}

function add_to_modify_line()
{
    CodePathFile=$WsRootDir/$CODEPATH/$1
    WindPathFile=$WINDPATH/$CODEPATH/$1
    
    if [ -d $CodePathFile ] ; then
        compare_folder $1
    else
        CMP_TMP=`cmp $CodePathFile $WindPathFile`
    
        if [ x"$CMP_TMP" != x"" ];then
            modify $1
        fi
    fi
}

function add()
{
    if [ ! -e $WsRootDir/.add_st_tmp ] ; then
        cp $WsRootDir/wind/scripts/.add_st_tmp $WsRootDir
    fi
    
    sed -i "/add end/i\\$1" $WsRootDir/.add_st_tmp
    FLAG_ADD=1
}

function add_all()
{
    TMPPATCH=$WsRootDir/$CODEPATH/

    while read line
    do
        if [ "`echo $line | grep -rsn '(use "git add <file>..." to include in what will be committed)'`" ];then
	        FLAG=1
	        continue
        fi

        if [ "`echo $line | grep -rsn 'no changes added to commit (use "git add" and/or "git commit -a")'`" ];then
	        FLAG=0
	        continue
        fi

        if [ "`echo $line | grep -rsn 'nothing added to commit but untracked files present'`" ];then
	        FLAG=0
	        continue
        fi
        
        if [ $FLAG == 1 ] && [ x"$line" != x"#" ];then
	        add ${line:2}
        fi

        if [ "`echo $line | grep -rsn 'modified'`" ];then
	        add ${line:14}
        fi    

    done < $WsRootDir/.st_tmp
}

function display_add()
{
    while read line
    do
        if [ "`echo $line | grep -rsn 'add start'`" ];then
	        FLAG=1
	        echo -e "\033[36m$line\033[0m"
	        continue
        fi
        
        if [ "`echo $line | grep -rsn 'add end'`" ];then
	        FLAG=0
	        echo -e "\033[36m$line\033[0m"
	        continue
        fi
                
        if [ $FLAG == 1 ];then
            echo -e "\033[31m        $line\033[0m"
        else
            echo -e "\033[34m$line\033[0m"
        fi

    done < $WsRootDir/.add_st_tmp

    if [ -e $WsRootDir/.add_st_tmp ] ; then
        rm -rf $WsRootDir/.add_st_tmp
    fi
}

function display_modify()
{
    while read line
    do
        if [ "`echo $line | grep -rsn 'modified start'`" ];then
	        FLAG=1
	        echo -e "\033[36m$line\033[0m"
	        continue
        fi
        
        if [ "`echo $line | grep -rsn 'modified end'`" ];then
	        FLAG=0
	        echo -e "\033[36m$line\033[0m"
	        continue
        fi
                
        if [ $FLAG == 1 ];then
            echo -e "\033[31m        $line\033[0m"
        else
            echo -e "\033[34m$line\033[0m"
        fi

    done < $WsRootDir/.modify_st_tmp

    if [ -e $WsRootDir/.modify_st_tmp ] ; then
        rm -rf $WsRootDir/.modify_st_tmp
    fi
}

function display()
{
    if [ $# -ge 1 ] && [ x"$1" == x"all" ];then
        if [ $FLAG_ADD == 1 ] || [ $FLAG_MODIFY == 1 ];then
            echo -e "\033[32m$CODEPATH\033[0m"
        fi
    fi
    
    if [ $FLAG_ADD == 1 ];then
        display_add
        FLAG_DISPLAY=1
    fi
    
    if [ $FLAG_MODIFY == 1 ];then
        display_modify
        FLAG_DISPLAY=1
    fi
    
    if [ $FLAG_ADD == 1 ] && [ $FLAG_MODIFY == 0 ];then
        echo -e "\033[34m# nothing added to commit but untracked files present (use "git add" to track)\033[0m"
    fi

    if [ $FLAG_MODIFY == 1 ];then
        echo -e "\033[34m# no changes added to commit (use "git add" and/or "git commit -a")\033[0m"
    fi
}

function display_all()
{
    while read line
    do
        if [ "`echo $line | grep -rsn 'project path='`" ]; then
            CODEPATH=`echo $line | awk -F "\"" '{print $2}'`
            if [ -d $WsRootDir/$CODEPATH ] && [ x"$CODEPATH" != x"wind" ]; then
                #echo -e "\033[32m$CODEPATH\033[0m"
                partial all
            fi
        fi

    done < $WsRootDir/.repo/manifests/default.xml
}

function partial()
{
    if [ -d $WsRootDir/$CODEPATH ]; then
        cd $WsRootDir/$CODEPATH/
        echo -e "\n" | git status . > $WsRootDir/.st_tmp
        cd $WsRootDir/
    else
        echo -e "\033[31mPlease check the path!!!\033[0m"
        exit 0
    fi

    if [ -e $WsRootDir/.st_tmp ] ; then
        if [ ! -s $WsRootDir/.st_tmp ] ; then
            rm -rf $WsRootDir/.st_tmp
            echo -e "\033[31mPlease check the path!!!\033[0m"
            exit 0
        fi
    fi

    TMPPATCH=$WsRootDir/$CODEPATH/

    if [ -e $WsRootDir/.add_st_tmp ] ; then
        rm -rf $WsRootDir/.add_st_tmp
    fi

    if [ -e $WsRootDir/.modify_st_tmp ] ; then
        rm -rf $WsRootDir/.modify_st_tmp
    fi
    
    if [ -d $WINDPATH/$CODEPATH ] ; then
        git_st
    else
        add_all
    fi

    if [ $# -ge 1 ] && [ x"$1" == x"all" ];then
        display all
    else
        display
    fi

    FLAG_ADD=0
    FLAG_MODIFY=0

    if [ -e $WsRootDir/.st_tmp ] ; then
        rm -rf $WsRootDir/.st_tmp
    fi    
}

function main()
{
    if [ $# -ge 1 ];then
        partial
    else
        display_all
    fi
    
    if [ $FLAG_DISPLAY == 0 ];then
        echo -e "\033[36mnothing to commit (working directory clean)\033[0m" 
    fi

    FLAG_DISPLAY=0
    
    if [ -e $WsRootDir/.st_tmp ] ; then
        rm -rf $WsRootDir/.st_tmp
    fi

    if [ -e $WsRootDir/.add_st_tmp ] ; then
        rm -rf $WsRootDir/.add_st_tmp
    fi
    
    if [ -e $WsRootDir/.modify_st_tmp ] ; then
        rm -rf $WsRootDir/.modify_st_tmp
    fi    
}

main $1 $2










