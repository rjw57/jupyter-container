FROM ipython/scipystack
MAINTAINER Rich Wareham <rich.compute-container@richwareham.com>

# Install a later version of CMake (needed for OpenCV install script)
RUN apt-get -y install software-properties-common && \
	add-apt-repository -y ppa:george-edison55/cmake-3.x && \
	apt-get -y update && apt-get -y install cmake

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

# Copy user skeleton and fix permissions
ADD user-skel "${USER_HOME_DIR}"
RUN chown -R "${USER_LOGIN}" "${USER_HOME_DIR}"

# Remainder of script runs as user in their home directory
USER "${USER_LOGIN}"
WORKDIR "${USER_HOME_DIR}"

# Run initial setup tasks
RUN setup/initial-setup.sh && setup/install-opencv.sh && rm -r setup/

EXPOSE 8888
CMD [ "/bin/bash", "-c", ". ~/.local/setup_vars.sh; jupyter notebook" ]
