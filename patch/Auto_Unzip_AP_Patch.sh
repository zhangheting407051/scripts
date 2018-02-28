#!/bin/bash

rm -rf ./Unzip_AP
mkdir Unzip_AP

for file_name in ./ALPS*.tar.gz ; do
    floder_name=${file_name%)*}
    floder_name=$floder_name")"
    mkdir ./Unzip_AP/$floder_name
    tar -xzvf $file_name -C ./Unzip_AP/$floder_name
done
