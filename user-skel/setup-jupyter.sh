#!/bin/bash
#
# Script to configure Jupyter kernels

# Ensure Python is setup
source ~/.bash_profile

# Log commands & exit on error
set -xe

# Install jupyter in python3
pip3 install jupyter

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

setup_jupyter python2 "Python 2"
setup_jupyter python3 "Python 3"
