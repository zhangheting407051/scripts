#!/bin/bash
#-*- coding: utf-8 -*-
echo "-----Modify annotation files start-----"

MATCH_LIST=`grep "@wind-mobi.com" -rl ./kernel-3.18`
for FILE in $MATCH_LIST;do
    echo "$FILE"
    sed -i "s/[a-zA-Z0-9]\+@wind-mobi.com/zte@zte.com.cn/g" $FILE
done

echo "-----Modify annotation files finish-----"

