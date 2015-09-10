FROM ubuntu:14.04
MAINTAINER Rich Wareham <rich.compute-container@richwareham.com>

# Install packages for compiling Python, OpenCV and the initial set of packages.
RUN apt-get -y update && apt-get -y install make build-essential libssl-dev \
	zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
	libncurses5-dev tk-dev liblapack-dev gfortran && apt-get -y build-dep opencv

# Enable installation of PPAs, git checkouts and install some other common
# programs,
RUN apt-get -y install software-properties-common git htop curl wget

# Install a later version of CMake
RUN add-apt-repository -y ppa:george-edison55/cmake-3.x && apt-get -y update && \
	apt-get -y install cmake

# Configure full name and login id for the compute user
ENV USER_LOGIN="${USER_LOGIN:-compute-user}" \
	USER_FULL_NAME="${USER_FULL_NAME:-Compute container user}"
ENV USER_HOME_DIR="/users/${USER_LOGIN}"

# Copy local configuration & fix perms
ADD conf /
RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*

# Create a new admin user
RUN addgroup compute-users
RUN adduser --disabled-password --home "${USER_HOME_DIR}" \
	--gecos "${USER_FULL_NAME},,," "${USER_LOGIN}" && \
	adduser "${USER_LOGIN}" compute-users

# Remainder of script runs as user in their home directory
USER "${USER_LOGIN}"
WORKDIR "${USER_HOME_DIR}"
RUN mkdir setup

# Install Python
ADD user/install-python.sh setup/
RUN setup/install-python.sh

# Install Python packages which need to be installed early
ADD user/install-python-pkgs.sh setup/
RUN setup/install-python-pkgs.sh

# Install any other packages listed in requirements.txt
ADD user/requirements.txt setup/
RUN bash -l -c "pip2 install -r setup/requirements.txt" && \
	bash -l -c "pip3 install -r setup/requirements.txt"

# Install latest OpenCV for Python
ADD user/install-opencv.sh setup/
RUN setup/install-opencv.sh

# Setup the jupyter kernels
ADD user/setup-jupyter.sh setup/
RUN setup/setup-jupyter.sh

# Remove setup scripts
RUN rm -r setup/

EXPOSE 8888
RUN mkdir -p notebooks
CMD [ "bash", "-l", "-c", \
	"SHELL=/bin/bash jupyter notebook --notebook-dir=\"${HOME}/notebooks\" --ip=0.0.0.0 --port=8888 --no-browser" \
]
