#!/bin/bash

#sdk link
SDK_LINUX='http://dl.google.com/android/android-sdk_r24.0.2-linux.tgz'
SDK_MAC='http://dl.google.com/android/android-sdk_r24.0.2-macosx.zip'
#define par
android_sdk_zip='android_sdk.zip'
android_sdk_folder='android-sdk-macosx'
sdk_target_place=~/Library/
profile_file=~/.bash_profile

#build the environment
echo 'download android sdk!'
curl -o ${android_sdk_zip} 

echo 'unzip android sdk!'
unzip ${android_sdk_zip}
rm ${android_sdk_zip}

echo 'write sdk to the enviroment file'
mv ${android_sdk_folder} ${sdk_target_place}

echo 'export android-sdk in profile'
echo 'export ANDROID_HOME= ${sdk_target_place}/${android_sdk_folder}' >> ${profile_file}
echo 'export PATH= ${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${PATH}'>> ${profile_file}

echo 'make profile effective'
source ${profile_file}

echo 'initiate android manager'
android

echo 'finished'
