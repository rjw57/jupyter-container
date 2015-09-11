#!/bin/bash
#
# Script to install OpenCV for the two Python versions in Pyenv

# Ensure Python is setup
source ~/.bash_profile

# Log commands & exit on error
set -xe

OPENCV_VER=3.0.0
OPENCV_CONTRIB_VER="${OPENCV_VER}"

# Pull out the Python versions from pyenv
PYTHON2_VER=$(pyenv versions | cut -f 2 -d ' ' | grep ^2 | head -1)
if [ -z "${PYTHON2_VER}" ]; then
	echo "Could not determine Python 2 version from pyenv." >&2
	exit 1
fi
PYTHON3_VER=$(pyenv versions | cut -f 2 -d ' ' | grep ^3 | head -1)
if [ -z "${PYTHON3_VER}" ]; then
	echo "Could not determine Python 3 version from pyenv." >&2
	exit 1
fi

# Create directory
OPENCV_PREFIX="${HOME}/opt/opencv"
mkdir -p "${OPENCV_PREFIX}"
cd "${OPENCV_PREFIX}"

# Download and extract OpenCV and OpenCV contrib modules
echo "Dowloading and extracting OpenCV..."
curl -L https://github.com/Itseez/opencv/archive/${OPENCV_VER}.tar.gz | tar xz
curl -L https://github.com/Itseez/opencv_contrib/archive/${OPENCV_CONTRIB_VER}.tar.gz | tar xz

echo "Compiling OpenCV..."
OPENCV_CONTRIB_MODULES=${OPENCV_PREFIX}/opencv_contrib-${OPENCV_CONTRIB_VER}/modules

# Get include and libraries for each python
pyenv shell ${PYTHON2_VER}
PY2_INCLUDE_DIRS=$(python-config --includes)
PY2_LIBRARY=${HOME}/.pyenv/versions/${PYTHON2_VER}/lib/lib$(python-config --libs | cut -f 1 -d ' ' | sed -e 's/^-l//').so
pyenv shell ${PYTHON3_VER}
PY3_INCLUDE_DIRS=$(python-config --includes)
PY3_LIBRARY=${HOME}/.pyenv/versions/${PYTHON3_VER}/lib/lib$(python-config --libs | cut -f 1 -d ' ' | sed -e 's/^-l//').so
pyenv shell --unset

echo "Python 2 include dir: ${PY2_INCLUDE_DIRS}"
echo "Python 2 library: ${PY2_LIBRARY}"
echo "Python 3 include dir: ${PY3_INCLUDE_DIRS}"
echo "Python 3 library: ${PY3_LIBRARY}"

cd opencv-${OPENCV_VER}
mkdir release; cd release
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/opt/opencv/ \
	-DOPENCV_EXTRA_MODULES_PATH=${OPENCV_CONTRIB_MODULES} \
	-DPYTHON2_INCLUDE_DIR=${PY2_INCLUDE_DIRS} \
	-DPYTHON2_INCLUDE_DIR2=${PY2_INCLUDE_DIRS} \
	-DPYTHON2_LIBRARY=${PY2_LIBRARY} \
	-DPYTHON3_INCLUDE_DIR=${PY3_INCLUDE_DIRS} \
	-DPYTHON3_INCLUDE_DIR3=${PY3_INCLUDE_DIRS} \
	-DPYTHON3_LIBRARY=${PY3_LIBRARY} \
	..

make && make install

# Configure shell to add OpenCV library to environment
cat >>~/.bashrc <<EOI
# Configure OpenCV
export OPENCV_PREFIX=\${HOME}/opt/opencv
export PATH="\${OPENCV_PREFIX}/bin:\${PATH}"
export LD_LIBRARY_PATH="\${OPENCV_PREFIX}/lib:\${LD_LIBRARY_PATH}"
for _pylib in \${OPENCV_PREFIX}/lib/python*/site-packages; do
	export PYTHONPATH="\${_pylib}:\${PYTHONPATH}"
done
EOI

