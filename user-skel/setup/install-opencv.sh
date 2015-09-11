#!/bin/bash
#
# Script to install OpenCV for the two Python versions in Pyenv

# Ensure Python is setup
source ~/.bash_profile

# Log commands & exit on error
set -xe

OPENCV_VER=3.0.0
OPENCV_CONTRIB_VER="${OPENCV_VER}"
OPENCV_INSTALL_PREFIX="${HOME}/.local"

# Create download directory
OPENCV_WORKDIR="$(mktemp -d --tmpdir opencv-compile.XXXXXX)"
cd "${OPENCV_WORKDIR}"

# Download and extract OpenCV and OpenCV contrib modules
echo "Dowloading and extracting OpenCV..."
curl -L https://github.com/Itseez/opencv/archive/${OPENCV_VER}.tar.gz | tar xz
curl -L https://github.com/Itseez/opencv_contrib/archive/${OPENCV_CONTRIB_VER}.tar.gz | tar xz

echo "Compiling OpenCV..."
OPENCV_CONTRIB_MODULES=${OPENCV_WORKDIR}/opencv_contrib-${OPENCV_CONTRIB_VER}/modules

cd opencv-${OPENCV_VER}
mkdir release; cd release
cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_PREFIX} \
	-DOPENCV_EXTRA_MODULES_PATH=${OPENCV_CONTRIB_MODULES} \
	..

make -j8 && make install

echo "Clearing up..."
rm -r "${OPENCV_WORKDIR}"

