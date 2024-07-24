# Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="chachoi@blackberry.com"
LABEL version="0.2.4"
LABEL description="Docker image for building projects for QNX."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Set locale
RUN apt-get clean && apt update && apt install -y locales software-properties-common
RUN locale-gen en_US en_US.UTF-8 && \
	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
	export LANG=en_US.UTF-8

# Add ROS2 apt repository
RUN apt update && apt install -y curl gnupg2 lsb-release && \
	curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
	sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# Build tools needed for building dependencies
RUN apt update && apt install -y \
	build-essential \
  	git \
  	libbullet-dev \
  	python3-colcon-common-extensions \
  	python3-flake8 \
	python3-pip \
	python3-pytest-cov \
	python3-rosdep \
	python3-setuptools \
	python3-vcstool \
	wget \
	bc \
	subversion \
	autoconf \
	libtool-bin \
	libssl-dev \
	zlib1g-dev \
	rename \
	rsync \
	xsltproc \
	libtool \
	automake \
	pkg-config \
	gfortran \
	vim \
	dos2unix

# Install python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
	apt update && \
	apt-get install -y \
	python3.11-dev \
	python3.11-venv \
	python3.11-distutils \
	rename

# Install CMake 3.22
RUN cd /opt && sudo wget https://cmake.org/files/v3.22/cmake-3.22.0-linux-x86_64.sh && \
	sudo mkdir /opt/cmake-3.22.0-linux-x86_64 && \
	yes | sudo sh cmake-3.22.0-linux-x86_64.sh --prefix=/opt/cmake-3.22.0-linux-x86_64 --skip-license && \
	sudo ln -s /opt/cmake-3.22.0-linux-x86_64/bin/cmake /usr/local/bin/cmake

# Adding user
ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG QNX_SDP_VERSION

ENV QNX_SDP_VERSION=$QNX_SDP_VERSION

ENV PS1='[QNX] (\u) \w$ '

RUN groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
	useradd --uid ${USER_ID} --gid ${GROUP_ID} --groups sudo --no-log-init --create-home ${USER_NAME} && \
	echo "${USER_NAME}:password" | chpasswd

# Create a folder for python venv
RUN mkdir -p /usr/local/qnx
RUN chown ${USER_NAME} /usr/local/qnx
USER ${USER_NAME}

# Install standard development tools
# Install pip packages needed for testing
# Needed to build numpy from source
RUN cd /usr/local/qnx && \
	python3.11 -m venv env && \
	. ./env/bin/activate && \
	python3 -m pip install -U \
	pip \
	empy \
	lark \
	Cython \
	wheel \
	colcon-common-extensions \
	vcstool \
	catkin_pkg \
	argcomplete \
	flake8-blind-except \
	flake8-builtins \
	flake8-class-newline \
	flake8-comprehensions \
	flake8-deprecated \
	flake8-docstrings \
	flake8-import-order \
	flake8-quotes \
	pytest-repeat \
	pytest-rerunfailures \
	pytest

WORKDIR /home/${USER_NAME}

# Welcome Message
COPY --chown=${USER_NAME}:${GROUP_NAME} ".qnxbashrc" "/usr/local/qnx"
COPY --chown=${USER_NAME}:${GROUP_NAME} "welcome.sh" "/usr/local/qnx"

CMD /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
