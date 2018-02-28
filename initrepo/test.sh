#!/bin/bash
echo $1 $2

cd $1
echo `pwd`
git remote rm STS001
git init

if [ x"`ls .`" = x ];then
    touch README
fi

git add .
git ci -a -m "init"
git remote add STS001 $2
git push STS001 master:master
cd -

