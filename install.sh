#!/bin/bash

ANDROID_DIR=`pwd`
Target="Nexus6P"
ANDROID_PATCHES="${ANDROID_DIR}/brahmaos-patches/${Target}"
Brahmagithub="https://github.com/BrahmaOS/"
BrahmaPrefix="brahmaos"
Packages='external/ipfs packages/apps/PrebuiltApps packages/apps/BrahmaSetup packages/apps/GoodWeather 
packages/apps/Update external/brahmaos-depends'

patchdirs=""

getpatchdir(){
	cd ${ANDROID_PATCHES}
	patchdirs=$(find -name *.patch  | xargs dirname | uniq | uniq | tr '\n' ' ' | tr -d '.')
	echo "Following dir should apply patches"
	echo "        ${patchdirs}"
	echo ""
}

clonepackage(){
	local package="$1"
	local packagedir=${package%/*}
	local target=${package##*/}
	local cloneaddr=`echo $package | sed 's/\//-/g'`
	packageurl="${Brahmagithub}${BrahmaPrefix}-${cloneaddr}"

	if [ ! -d ${packagedir} ];then
		mkdir -p ${packagedir}
	fi

	cd ${packagedir}
	git clone ${packageurl} ${target}
	cd ${ANDROID_DIR}
}

importpackages(){
	for package in $Packages;
	do
		clonepackage $package
	done
}

### apply one git repository patches###
### $1 : subdir    ####################

applydirpatch()
{
	local subpatchdir="$1"
	local gitrepository="${ANDROID_DIR}${subpatchdir}"
	## Checking whether it's a git repository, if not, exit ###
        ## If yes, applying all the patches                    ###
	local successflag=1
	if [ -d "${gitrepository}/.git" ];then
		cd ${gitrepository}
		for patchfile in ${ANDROID_PATCHES}${subpatchdir}/*.patch;do
			git am $patchfile
		        if [ $? -eq 0 ];then
	                        echo "  Apply $patchfile Succeed"
				echo ""
               		else
                        	echo "  Failed"
				successflag=0
				break;
			fi
		done
	else
		echo "Error: ${gitrepository} is not git repository"
		successflag=0
	fi

	if [ $successflag -eq 0 ];then
		cd ${ANDROID_DIR}
		exit 1
	fi
	cd ${ANDROID_DIR}
}


### apply all patches###########
applyallpatches()
{
	for onedir in ${patchdirs};do
		echo -e "\033[31m APPLYING THE PATCHES IN ${onedir} \033[0m"
		applydirpatch ${onedir}
		echo ""
	done
}

## to be implemented
resetallpatches()
{
	echo "Reseting all patches"
}

echo "ANDROID_DIR=${ANDROID_DIR}"


getpatchdir
if [ $# -eq 1 ];then
	if [ $1 == 'reset' ];then
		resetallpatches		
	fi
else
     applyallpatches
fi
importpackages
