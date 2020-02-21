#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
KERNELVER="raspberrypi-kernel_1.20200212-1"

echo "--- Running in ${DIR}"

if [ -d "${DIR}/tools" ]; then
    echo "Cross compiler already cloned"
else
    echo "Cloning cross compiler to ${DIR}/tools"
    git clone --depth=1 https://github.com/raspberrypi/tools "${DIR}/tools"
fi

if [ -d "${DIR}/linux" ]; then
    echo "Kernel sources already cloned"
else
    echo "Cloning kernel with tag ${KERNELVER} to ${DIR}/linux"
    git clone --depth=1 -b ${KERNELVER} https://github.com/raspberrypi/linux "${DIR}/linux"
fi

if [ -d "${DIR}/Firmware" ]; then
    echo "Firmware template already cloned"
else
    echo "Cloning firmware template to ${DIR}/Firmware"
    git clone --depth=1 https://github.com/RPi-Distro/Firmware "${DIR}/Firmware"
fi

echo "--- Adding cross-compilers to PATH"

OLDPATH=$PATH
export PATH="${PATH}:${DIR}/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin"

echo "--- Clearing kernel tree"
cd "${DIR}/linux"
make mrproper

echo "--- Building kernel for Raspberry Pi 1, Zero, Zero W, Compute Module v1"

mkdir -p "${DIR}/output/kernel_pi1/overlays"
mkdir -p "${DIR}/output/kernel_pi1/modules"
mkdir -p "${DIR}/output/kernel_pi1/headers"

cd "${DIR}/linux"
KERNEL=kernel make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcmrpi_defconfig
KERNEL=kernel make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH="${DIR}/output/kernel_pi1/modules" modules_install
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_HDR_PATH="${DIR}/output/kernel_pi1/headers" headers_install
cp arch/arm/boot/zImage "${DIR}/output/kernel_pi1"
cp arch/arm/boot/dts/*.dtb "${DIR}/output/kernel_pi1/overlays/"
cp arch/arm/boot/dts/overlays/*.dtb* "${DIR}/output/kernel_pi1/overlays/"
cp arch/arm/boot/dts/overlays/README "${DIR}/output/kernel_pi1/overlays/"

echo "--- Clearing kernel tree"
cd "${DIR}/linux"
make mrproper

echo "--- Building kernel for Raspberry Pi 2, 3, 3+, Compute Module v3"

mkdir -p "${DIR}/output/kernel_pi3/overlays"
mkdir -p "${DIR}/output/kernel_pi3/modules"
mkdir -p "${DIR}/output/kernel_pi3/headers"

cd "${DIR}/linux"
KERNEL=kernel7 make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
KERNEL=kernel7 make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH="${DIR}/output/kernel_pi3/modules" modules_install
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_HDR_PATH="${DIR}/output/kernel_pi3/headers" headers_install
cp arch/arm/boot/zImage "${DIR}/output/kernel_pi3"
cp arch/arm/boot/dts/*.dtb "${DIR}/output/kernel_pi3/overlays/"
cp arch/arm/boot/dts/overlays/*.dtb* "${DIR}/output/kernel_pi3/overlays/"
cp arch/arm/boot/dts/overlays/README "${DIR}/output/kernel_pi3/overlays/"

echo "--- Clearing kernel tree"
cd "${DIR}/linux"
make mrproper

echo "--- Building kernel for Raspberry Pi 4"

mkdir -p "${DIR}/output/kernel_pi4/overlays"
mkdir -p "${DIR}/output/kernel_pi4/modules"
mkdir -p "${DIR}/output/kernel_pi4/headers"

cd "${DIR}/linux"
KERNEL=kernel make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2711_defconfig
KERNEL=kernel make -j12 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH="${DIR}/output/kernel_pi4/modules" modules_install
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_HDR_PATH="${DIR}/output/kernel_pi4/headers" headers_install
cp arch/arm/boot/zImage "${DIR}/output/kernel_pi4"
cp arch/arm/boot/dts/*.dtb "${DIR}/output/kernel_pi4/overlays/"
cp arch/arm/boot/dts/overlays/*.dtb* "${DIR}/output/kernel_pi4/overlays/"
cp arch/arm/boot/dts/overlays/README "${DIR}/output/kernel_pi4/overlays/"

echo "--- Restoring old path"
export PATH=$OLDPATH

echo "--- Copying build artifacts to firmware template"

cp "${DIR}/output/kernel_pi1/zImage" "${DIR}/Firmware/boot/kernel.img"
cp "${DIR}/output/kernel_pi3/zImage" "${DIR}/Firmware/boot/kernel7.img"
cp "${DIR}/output/kernel_pi4/zImage" "${DIR}/Firmware/boot/kernel7l.img"
cp ${DIR}/output/kernel_pi4/overlays/*.dtb "${DIR}/Firmware/boot"
cp ${DIR}/output/kernel_pi4/overlays/*.dtbo "${DIR}/Firmware/boot/overlays"

echo "--- Generating packages"

cd "${DIR}/Firmware"
fakeroot debian/rules binary
