#!/usr/bin/bash

#BUILD FROM SCRIPT:

checkout(){
#	echo "TODO:______ CHECKOUT -> Verify if clean - no commits pendig, etc"
	echo "______ CHECKOUT $CURRENT_BUILD_BRANCH .................... -START-"
	git checkout $CURRENT_BUILD_BRANCH
	echo "______ CHECKOUT $CURRENT_BUILD_BRANCH .................... -DONE-"
}

update_version_var(){
	VERSION=`grep android:versionCode AndroidManifest.xml | sed 's/.*versionCode="//g' | sed 's/".*//g'`
}

update_versiune_txt(){
	echo "______ updating versiune.txt ........... -START-"
	mkdir -p $prj_dir/assets/data/SDCard/Books/
	echo -n $VERSION> $prj_dir/assets/data/SDCard/Books/versiune.txt
	echo "______ updating versiune.txt ........... -DONE-"
}

build_any(){
	echo "______ BUILDING $CURRENT_BUILD_BRANCH .................... -START-"
	echo "____________ Cleaning (and distclean).....: "
	ant distclean
	echo "____________ Building Native ($NDK/ndk-build.cmd).....: "
	$NDK/ndk-build.cmd
	echo "____________ Building release (ant release).....: "
	ant release
	echo "______ BUILDING $CURRENT_BUILD_BRANCH .................... -DONE-(not verified yet)"
}	

apk_save(){

	echo "______ TEST BUILD & SAVE NEW APK  .......  ..... -START-"

	SRC_APK_FULLPATH_NAME=`ls $prj_dir/bin/*-release.apk`
	APK_NAME=`ls $prj_dir/bin/ | grep "-release.apk"`
	NEW_APK_NAME=${VERSION}_${CURRENT_BUILD_BRANCH}.${APK_NAME}
	
	if [[ -n ${NEW_APK_NAME} ]];then
		echo "______ SAVING $NEW_APK_NAME in $out_dir .......  ..... -START-"
		mv $out_dir/${NEW_APK_NAME} $out_dir/old.${NEW_APK_NAME}.PID.$$ 2>&-   # I do not care if fails...
		cp ${SRC_APK_FULLPATH_NAME} $out_dir/${NEW_APK_NAME}
		echo "Here is the new APK: `ls -la $out_dir/${NEW_APK_NAME}`"
		echo "______ SAVING the APK in $out_dir .................... -DONE-"
	else
		echo "Most probably BUILD FAILED, we could not find any APK in the: $prj_dir/bin/"
		echo "This is the ls output: `ls $prj_dir/bin/`"
	fi

	echo "______ TEST BUILD & SAVE NEW APK  .......  ..... -DONE-"

}

return_to_master(){
	CURRENT_BUILD_BRANCH="master"
	checkout
}

show_status(){
	echo " "
	echo "`git branch`"
	echo "`git status`"
}

byebye(){
	echo "$0 - WORK DONE. Bye"
}

usage(){
	echo "Use like this: \n $0 <branch> \n or \n $0 all"
	echo "Detected branches are: $VALID_BRANCHES"
}

do_all(){
	checkout
	adb kill-server #To ensure the folders are not locked
	update_version_var #updates $VERSION
	update_versiune_txt
	build_any
	apk_save
}

############# MAIN #########
############################

shopt -s extglob  # A must for the case to eval the variable
prj_dir=/cygdrive/c/_me/android/_epub/workspace/Acatiste_Rugaciuni_Scrieri_Ortodoxe_GIT/git/acatiste.rugaciuni.biblia.ortodox/
out_dir=/cygdrive/c/_me/android/_KeyStore/
cd $prj_dir
all_braches=`git branch | tr "*" " " | cut -d " " -f 3`
VALID_BRANCHES=`echo $all_braches | tr " " "|"`

echo "Branch(s) to be build:$1"

case $1 in 
	all)
		for B in ${all_braches}
		do
			export CURRENT_BUILD_BRANCH=${B}
			do_all
		done
		return_to_master
		show_status
		byebye
		;;
	@($VALID_BRANCHES))
		export CURRENT_BUILD_BRANCH=${1}
		do_all
		return_to_master
		show_status
		byebye
		;;
	*)	echo "ERROR: Invalid branch !"
		usage
		;;
esac


