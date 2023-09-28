#!/bin/bash

#set -e

KERNEL_DEFCONFIG=vendor/lmi_user_defconfig
ANYKERNEL3_DIR=$PWD/AnyKernel3/
FINAL_KERNEL_ZIP=Perf_LMI_v295_A13_raystef66.zip

# paths
TC="/home/raystef66/kernel/prebuilts"

PATH=${TC}/clang-r416183b1/bin:${TC}/aarch64/bin:${TC}/arm/bin:$PATH

export LLVM=1
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
export USE_CCACHE=1

# Speed up build process
MAKE="./makeparallel"

make O=out ARCH=arm64 vendor/lmi_user_defconfig

START=$(date +"%s")

make ARCH=arm64 \
        O=out \
        CC=clang \
		AR=llvm-ar \
        LD=ld.lld \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        -j$(nproc --all)
               

echo -e "$yellow**** Verify Image.gz-dtb & dtbo.img ****$nocol"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb
ls $PWD/out/arch/arm64/boot/dtbo.img

echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR
echo -e "$yellow**** Removing leftovers ****$nocol"
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf $ANYKERNEL3_DIR/dtbo.img
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Copying Image.gz-dtb & dtbo.img ****$nocol"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/
cp $PWD/out/arch/arm64/boot/dtbo.img $ANYKERNEL3_DIR/

echo -e "$yellow**** Time to zip up! ****$nocol"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP /home/raystef66/kernel/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Done, here is your checksum ****$nocol"
cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf $ANYKERNEL3_DIR/dtbo.img
rm -rf out/

END=$(date +"%s")
DIFF=$((END - START))
echo -e '\033[01;32m' "Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds" || exit
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
