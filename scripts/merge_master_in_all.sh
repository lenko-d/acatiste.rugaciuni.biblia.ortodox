#!/bin/sh

checkout(){
	echo "TODO:______ CHECKOUT -> Verify if clean - no commits pendig, etc"
	echo "______ CHECKOUT $CURRENT_BUILD_BRANCH .................... -START-"
	git.cmd checkout $CURRENT_BUILD_BRANCH
	echo "______ CHECKOUT $CURRENT_BUILD_BRANCH .................... -DONE-"
}

merge(){
	echo "TODO:______ MERGING -> Verify if clean - no commits pendig, etc"
	echo "______ MERGING $SourceBranch in $CURRENT_BUILD_BRANCH ....... -START-"
	git.cmd merge $SourceBranch
	echo "______ MERGING $SourceBranch in $CURRENT_BUILD_BRANCH ....... -DONE-"
}

do_all(){
	checkout
	merge
}

return_to_master(){
	CURRENT_BUILD_BRANCH="master"
	checkout
}

show_status(){
	echo " "
	echo "`git.cmd branch`"
	echo "`git.cmd status`"
}

byebye(){
	echo "$0 - WORK DONE. Bye"
}

usage(){
	echo "Use like this: \n $0 <branch from where to read the new data for merge in all others>(e.g.: master)."
	echo "Detected branches are: ${VALID_BRANCHES}"
	echo "Current branch is: ${current_brach}"
}

############# MAIN #########
############################

shopt -s extglob  # A must for the case to eval the variable
prj_dir=/cygdrive/c/_me/android/_epub/workspace/Acatiste_Rugaciuni_Scrieri_Ortodoxe_GIT/git/acatiste.rugaciuni.biblia.ortodox/
cd $prj_dir
all_braches=`git.cmd branch | tr "*" " " | cut -d " " -f 3`
current_brach=`git.cmd branch | grep "*"`
VALID_BRANCHES=`echo $all_braches | tr " " "|"`

SourceBranch=$1 #usually master

case $SourceBranch in 
	@($VALID_BRANCHES))
		for B in ${all_braches}
		do
			if [[ $B = $SourceBranch ]]; then
				continue
			fi
			CURRENT_BUILD_BRANCH=${B}
			do_all
		done
		
		return_to_master
		show_status
		byebye
		
		;;
	*)	echo "ERROR: Invalid source branch !"
		usage
		;;
esac
