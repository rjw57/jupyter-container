FROM ipython/scipystack
MAINTAINER Rich Wareham <rich.compute-container@richwareham.com>

# Install some useful packages
RUN apt-get -y install vim git htop python-dev python3-dev

# Install a later version of CMake (needed for OpenCV install script)
RUN apt-get -y install software-properties-common && \
	add-apt-repository -y ppa:george-edison55/cmake-3.x && \
	apt-get -y update && apt-get -y install cmake

# Copy local configuration & fix perms
ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && chmod 0440 /etc/sudoers.d/*
RUN addgroup compute-users

# Run any system setup
ADD setup /tmp/setup
RUN cd /tmp/setup && ./setup-system.sh && rm -r /tmp/setup

EXPOSE 8888
ADD run.sh /opt/compute-container/run.sh
CMD /opt/compute-container/run.sh

