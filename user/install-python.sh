#!/bin/bash
#
# Script to install Python 2 and Python 3 via pyenv inside a user's home
# directory.

# Versions of Python to install
PYTHON3_VER=3.4.3
PYTHON2_VER=2.7.10

# Log commands & exit on error
set -xe

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

# Install Python(s)
echo "Installing Python 3..."
CFLAGS="-O2" PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "${PYTHON3_VER}"
echo "Installing Python 2..."
CFLAGS="-O2" PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install "${PYTHON2_VER}"

echo "Configuring default Python versions for user..."
pyenv global "${PYTHON3_VER}" "${PYTHON2_VER}"

