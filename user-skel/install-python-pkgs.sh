#!/bin/bash
#
# Script to install useful Python packages for a user.

# Packages to install in Python. These are the packages which almost every othe
# package depends on in some way.
PYTHON_PKGS="pip numpy scipy"

# Ensure Python is setup
source ~/.bash_profile

# Log commands & exit on error
set -xe

echo "Installing Python packages..."
for pkg in ${PYTHON_PKGS}; do
	pip2 install --upgrade "${pkg}"
	pip3 install --upgrade "${pkg}"
done

