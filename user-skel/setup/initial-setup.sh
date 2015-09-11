#!/bin/bash
#
# Initial setup script for compute machine

# Log commands & exit on error
set -xe

echo "Copying dotfiles..."
for _df in "${HOME}"/dotfiles/*; do
	_bn="$(basename "${_df}")"
	echo " - ${_bn}"
	cp -rapv "${_df}" "${HOME}"/."${_bn}"
done
echo "Removing original dotfile directory..."
rm -r "${HOME}/dotfiles"

echo "Configuring environment..."
_local_dir="${HOME}/.local"
mkdir -p "${_local_dir}"
_setup_vars_sh="${_local_dir}/setup_vars.sh"
cat >"${_setup_vars_sh}" <<EOI
export PATH="${_local_dir}/bin:\${PATH}"
export LD_LIBRARY_PATH="${_local_dir}/lib:\${LD_LIBRARY_PATH}"
EOI
cat >>"${HOME}/.bashrc" <<EOI
source "\${HOME}/.local/setup_vars.sh"
EOI

# make sure that .local appears on the path for the rest of the script
source "${_setup_vars_sh}"

for _pip in pip2 pip3; do
	echo "Upgrading ${_pip}..."
	${_pip} install --upgrade pip

	echo "Installing remaining requirements via ${_pip}..."
	${_pip} install --upgrade -r setup/requirements.txt
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
	jupyter kernelspec install --user "${_spec_dir}"
	rm -r "${_ktmp}"
}

echo "Configuring Jupyter notebook server for Python 2 and 3..."
setup_jupyter python2 "Python 2"
setup_jupyter python3 "Python 3"

