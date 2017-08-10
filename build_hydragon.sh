#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image"
DTBIMAGE="dtb"
DEFCONFIG="hydragon_crackling_defconfig"

#hydragon Kernel Details
KERNEL_NAME="HYDRAGON"
VER="-$(date +"%Y%m%d")"

# Vars
BASE_hydragon_VER="hydragon"
hydragon_VER="$BASE_hydragon_VER$VER$TC"
export LOCALVERSION=~`echo $hydragon_VER`
export LOCALVERSION=~`echo $hydragon_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=ashnwor
export KBUILD_BUILD_HOST=arch

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="$KERNEL_DIR/.."
ANYKERNEL_DIR="$RESOURCE_DIR/AnyKernel2-crackling"
TOOLCHAIN_DIR="/home/$USER/development/toolchains"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/hydragon-releases"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

# Functions
function clean_all {
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf ${HOME}/development/crackling/arch/arm64/boot/dt.img
		cd ${HOME}/development/AnyKernel2-crackling/
		rm -rf zImage
		rm -rf $DTBIMAGE
		rm -rf $KERNEL
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		#find $MODULES_DIR/proprietary -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		cd $MODULES_DIR
        $STRIP --strip-unneeded *.ko
        cd $KERNEL_DIR
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -v2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
		cp -vr $KERNEL_DIR/arch/arm64/boot/dt.img $REPACK_DIR/dtb
}

function make_zip {
		cd $REPACK_DIR
		zip -x@zipexclude -r9 `echo $hydragon_VER`.zip *
		mv  `echo $hydragon_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "--------------------------------------------------------"
echo "Welcome $USER !   Initiating To Compile $BASE_hydragon_VER$VER    "
echo "--------------------------------------------------------"
echo -e "${restore}"

echo -e "${cyan}"
while read -p "Plese Select Desired Toolchain for compiling $KERNEL_NAME

UBERTC-7.0---->(1)

" echoice
do
case "$echoice" in

	1 )
		export CROSS_COMPILE=${HOME}/development/toolchains/aarch64-linux-android-7.0-UBERTC/bin/aarch64-linux-android-
		STRIP=${HOME}/development/toolchains/aarch64-linux-android-7.0-UBERTC/bin/aarch64-linux-android-strip
		TC="UBERTC-7.0"
		echo
		echo "Compiling $KERNEL_NAME Using UBERTC-7.0 Toolchain"
		break
		;;
		
	2 )
		export CROSS_COMPILE=${HOME}/development/toolchains/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-
		STRIP=${HOME}/development/toolchains/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-strip
		TC="UBERTC-4.9"
		echo
		echo "Compiling $KERNEL_NAME Using UBERTC-4.9 Toolchain"
		break
		;;

	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
echo -e "${red}"
while read -p "Clean build ?
Y or N

" cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "Build directory has been cleaned."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
while read -p "Do you want to start compiling of $KERNEL_NAME ?

Yes Or No ?

Enter Y for Yes Or N for No

" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_dtb
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${green}"
echo "------------------------------------------"
echo "Build $hydragon_VER Completed :"
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
