#!/bin/bash

rm -rf ./Unzip_Modem
mkdir Unzip_Modem

for file_name in ./MOLY*.tar.gz ; do
    floder_name=${file_name%)*}
    floder_name=$floder_name")"
    mkdir ./Unzip_Modem/$floder_name
    tar -xzvf $file_name -C ./Unzip_Modem/$floder_name
done
