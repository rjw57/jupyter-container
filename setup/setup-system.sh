#!/bin/bash
#
# Initial setup script for compute machine

# Log commands & exit on error
set -xe

OPENCV_VER=3.0.0
OPENCV_CONTRIB_VER="${OPENCV_VER}"
OPENCV_INSTALL_PREFIX="/opt/opencv"
PYTHON_PACKAGES="ipython jupyter"

for _pip in pip2 pip3; do
	echo "Upgrading ${_pip}..."
	${_pip} install --upgrade pip

	echo "Installing remaining requirements via ${_pip}..."
	for _pkg in ${PYTHON_PACKAGES}; do
		${_pip} install --upgrade "${_pkg}"
	done
done

function setup_jupyter() {
	_python=$1
	_name=$2

	_ktmp=$(mktemp -d kernelspecs-XXXXXXX)
	echo "Setting up Jupyter for ${_python}"
	_spec_dir="${_ktmp}/$(basename ${_python})"
	mkdir -p "${_spec_dir}"
	cat >"${_spec_dir}/kernel.json" <<EOI
{
	"language": "python",
	"display_name": "${_name}",
	"argv": [
		"${_python}", "-m", "ipykernel", "-f", "{connection_file}"
	]
}
EOI
	jupyter kernelspec install "${_spec_dir}"
	rm -r "${_ktmp}"
}

echo "Configuring Jupyter notebook server for Python 2 and 3..."
setup_jupyter python2 "Python 2"
setup_jupyter python3 "Python 3"

function install_opencv() {
	echo "Installing OpenCV..."

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

	# Add OpenCV to profile
	cat >>/etc/profile.d/opencv.sh <<EOI
export OPENCV_PREFIX="${OPENCV_INSTALL_PREFIX}"
export PATH="\${OPENCV_PREFIX}/bin:\${PATH}"
export LD_LIBRARY_PATH="\${OPENCV_PREFIX}/lib:\${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="\${OPENCV_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH}"
for _pp in "\${OPENCV_PREFIX}"/lib/python*/dist-packages; do
	export PYTHONPATH="\${_pp}:\${PYTHONPATH}"
done
EOI

	echo "Deleting OpenCV build directory..."
	rm -r "${OPENCV_WORKDIR}"
}

install_opencv

