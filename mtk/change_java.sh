#!/bin/bash
USAGE="Usage: command [version] \n
        version -- java version e.g. 1.7."

java_version=$1

if [ x"$java_version" = "x" ];then
    echo -e $USAGE
    return 1
elif [ ${#java_version} -ne 3 ];then
    echo "Jdk version option's length must be 3"
    return 1
fi

JVM_PATH="/usr/lib/jvm"
contains=`ls $JVM_PATH`

if [ x"$contains" = "x" ];then
    echo "There is no jdk in $JVM_PATH"
    return 1
else
    existedFlag=0
    for folder in $contains;do
        if [ ${folder:5:3} = $java_version ];then
            existedFlag=1
            export PATH=$JVM_PATH/$folder/bin:$PATH
            echo "Change java env to jdk"$java_version
        fi
    done
    if [ $existedFlag -eq 0 ];then
        echo "Jdk "$java_version" is not existed."
        return 1
    fi
fi

return 0
