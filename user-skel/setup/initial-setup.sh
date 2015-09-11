#!/bin/bash
#
# Initial setup script for compute machine

# Versions of Python to install
PYTHON3_VER=3.4.3
PYTHON2_VER=2.7.10

# Log commands & exit on error
set -xe

function main() {
	install_pyenv
	install_pythons

	echo "Configuring default Python versions for user..."
	pyenv global "${PYTHON3_VER}" "${PYTHON2_VER}"

	echo "Installing initial package set..."
	for _pkg in pip numpy scipy ipython jupyter; do
		pip2 install --upgrade ${_pkg}
		pip3 install --upgrade ${_pkg}
	done

	echo "Configuring Jupyter notebook server for Python 2 and 3..."
	setup_jupyter python2 "Python 2"
	setup_jupyter python3 "Python 3"

	echo "Installing remaining requirements..."
	pip2 install -r setup/requirements.txt
	pip3 install -r setup/requirements.txt
}

function install_pyenv() {
	# Install and configure pyenv
	echo "Installing pyenv..."
	git clone https://github.com/yyuu/pyenv.git ~/.pyenv
	cat >>~/.bash_profile <<EOI
export PATH="\${HOME}/.pyenv/bin:\${PATH}"
eval "\$(pyenv init -)"
EOI
	cat >>~/.bashrc <<EOI
source "\${HOME}/.bash_profile"
EOI

	# Setup pyenv for the remainder of this script
	export PATH="${HOME}/.pyenv/bin:${PATH}"
	eval "$(pyenv init -)"
}

function install_pythons() {
	# Install Python(s)
	echo "Installing Python 3..."
	CFLAGS="-O2" PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "${PYTHON3_VER}"
	echo "Installing Python 2..."
	CFLAGS="-O2" PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "${PYTHON2_VER}"
}

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
	jupyter kernelspec install --user "${_spec_dir}"
	rm -r "${_ktmp}"
}

main
