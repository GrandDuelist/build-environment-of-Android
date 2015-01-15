	#!/bin/sh
target_device_name='T3'
target_api='android-18'
install_api='18'

default_api="19"  #android 4.4.2

#sdk link
SDK_LINUX='http://dl.google.com/android/android-sdk_r24.0.2-linux.tgz'
SDK_MAC='http://dl.google.com/android/android-sdk_r24.0.2-macosx.zip'

#default sdk local folder
SDK_FOLDER=~/.android_sdk 

#define par
android_sdk_mac=android_sdk.zip
android_sdk_linux=android_sdk.tgz

android_sdk_folder=android-sdk-macosx
sdk_target_place=~/Library/
profile_file_mac=~/.bash_profile
profile_file_linux=~/.bashrc
#build android_home
build_android_home()
{
	#create default folder
	if [ ! -d "$SDK_FOLDER" ]; then
		echo "create sdk folder ${SDK_FOLDER}"
		mkdir "$SDK_FOLDER"
	fi
    
    cd "$SDK_FOLDER"
	
	#download sdk
	echo "download sdk from google"	
	if [ "Linux" = $SYSTEM ]; then
		echo "download sdk for linux system" 
  		curl -o "$android_sdk_linux" "$SDK_LINUX" 
  		
  		echo "download finished, begin to unzip file"
  		tar xzxf "$android_sdk_linux"
  		
  		echo "unzip finished, remove $android_sdk_linux"
  		rm "$android_sdk_linux"
  		
  		cd *
  		mv * ..
        cd ../tools

        echo "download platform-tools,tools,build-tools,android-$default_api"
        ./android update sdk --all --filter  platform-tool,tool,build-tool-21.1.2,android-$default_api,sys-img-armeabi-v7a-android-$default_api --no-ui
  		echo 'export android-sdk in profile'
        echo 'export ANDROID_HOME='$SDK_FOLDER >> $profile_file_linux
        echo 'export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}'>> ${profile_file_linux}
		source "$profile_file_linux"
        echo "ANDROID_HOME set finished"
		

	elif [ $SYSTEM = "Darwin" ]; then
 		echo "download sdk for mac system"
 		curl -o "$android_sdk_mac" "$SDK_MAC"	

 		echo "download finished, begin to unzip file"
  		unzip "$android_sdk_mac"
  		
  		echo "unzip finished, remove $android_sdk_linux"
  		rm "$android_sdk_mac"
  		
  		cd *
  		mv * ..
        cd ../tools

        echo "download platform-tools,tools,build-tools,android-$default_api"
        ./android update sdk --all --filter  platform-tool,tool,build-tool-21.1.2,android-$default_api,sys-img-armeabi-v7a-android-$default_api --no-ui
  		echo 'export android-sdk in profile'
        echo 'export ANDROID_HOME='$SDK_FOLDER >> $profile_file_mac
        echo 'export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}'>> ${profile_file_mac}
		source "$profile_file_mac"
        echo "ANDROID_HOME set finished"

	fi

}

#test if target api has been installed
target_api_is_installed()
{

	#number of target
	target=$1
	absoluate_path="$SDK_FOLDER/platforms/$target"
	echo "$absoluate_path"
	if [ -d "$absoluate_path" ]; then
		echo 'the target '$target' has been existed'
		return 1
	else
		echo "download target $target"
		#cd $SDK_MAC_FOLDER/platform-tools
		android update sdk --all --filter android-$target,sys-img-armeabi-v7a-android-$target  --no-ui
	#	echo 'api '$target' has been installed'	
	fi

	return 0;
}

#if avd with specific target existed, then return true
is_virtual_machine_existed()
{
	target=$1
	result=`android list avd`
	#result=$?	
	is_contained=`echo $result|grep 'API level '$target`;
	if [ "" != "$is_contained" ]; then
		echo "exist"
		return 1  #exist
	fi
		echo "not exist"
	return 0  #not exist
}


#create virtual create_virtual_machine
create_virtual_machine()
{
	install_target=$1
	device_name=$2
	echo "create virtual device with android api $install_target"
	
	echo "find if the android device existed"
	is_virtual_machine_existed $install_target
	is_existed=$?		

	 if [ 1 -eq $is_existed ]; then
	  	echo "the device with API $install_target existed"
	 else 
	 	echo "the device with API $install_target not exist, create new one"	
	 	
	 	absoluate_path="$SDK_FOLDER/system-images/android-$install_target"
		echo "$absoluate_path"
		absoluate_path2="$absoluate_path/default"
		echo "$absoluate_path2"

		if [ -d "$absoluate_path" -a -d "$	absoluate_path2" ]; then
			echo 'the target '$install_target' has been existed'
			
		else
			echo "download target $install_target"
			#cd $SDK_MAC_FOLDER/platform-tools
			android update sdk --all --filter sys-img-armeabi-v7a-android-$install_target  --no-ui
		#	echo 'api '$target' has been installed'	
		fi
	 	android create avd -n $device_name -d Nexus\ 4 -t android-$install_target --abi default/armeabi-v7a		
	 fi
}


#launch the target virtual device
launch_virtual_machine()
{
	device_name=$1
	echo "launch android virtual device $device_name"	
	emulator -avd $device_name -gpu on
}

#define command
SYSTEM=`uname -s`
#test ANDROID_HOME IS OK
if [ -z $ANDROID_HOME ]; then
	echo "ANDROID_HOME has not been set, start to build environment..."
	build_android_home
else
	echo "ANDORID_HOME is ok, start to download target android api"
	SDK_FOLDER=$ANDROID_HOME
fi





if [ "Linux" = $SYSTEM ]; then 
  	echo "Linux"
  	#download uninstalled target 
	target_api_is_installed $target_api

	#create target api virtual machine
	create_virtual_machine $install_api $target_device_name

	#launch target virtual mechine
	launch_virtual_machine $target_device_name
elif [ $SYSTEM = "Darwin" ]; then
 	echo "Mac"
 	#download uninstalled target 
	target_api_is_installed $target_api

	#create target api virtual machine
	create_virtual_machine $install_api $target_device_name

	#launch target virtual mechine
	launch_virtual_machine $target_device_name	
fi
exit 0
	#statements
#get the computer system type -- linux mac