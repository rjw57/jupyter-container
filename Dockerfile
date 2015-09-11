FROM ubuntu:14.04
MAINTAINER Rich Wareham <rich.compute-container@richwareham.com>

# Install packages for compiling Python and the initial set of packages.
RUN apt-get -y update && apt-get -y install make build-essential libssl-dev \
	zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
	libncurses5-dev tk-dev liblapack-dev gfortran

# Enable installation of PPAs, git checkouts and install some other common
# programs,
RUN apt-get -y install software-properties-common git htop curl wget

# Install a later version of CMake (needed for OpenCV install script)
RUN add-apt-repository -y ppa:george-edison55/cmake-3.x && apt-get -y update && \
	apt-get -y install cmake

# Configure full name and login id for the compute user
ENV USER_LOGIN="${USER_LOGIN:-compute-user}" \
	USER_FULL_NAME="${USER_FULL_NAME:-Compute container user}"
ENV USER_HOME_DIR="/users/${USER_LOGIN}"

# Copy local configuration & fix perms
ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*

# Create a new admin user
RUN addgroup compute-users
RUN adduser --disabled-password --home "${USER_HOME_DIR}" \
	--gecos "${USER_FULL_NAME},,," "${USER_LOGIN}" && \
	adduser "${USER_LOGIN}" compute-users

# Remainder of script runs as user in their home directory
USER "${USER_LOGIN}"
WORKDIR "${USER_HOME_DIR}"

# Copy user skeleton and configuration
ADD user-skel .
ADD dot-jupyter .jupyter

# Run initial setup
RUN setup/initial-setup.sh

EXPOSE 8888
CMD [ "bash", "-l", "-c", "jupyter notebook" ]
