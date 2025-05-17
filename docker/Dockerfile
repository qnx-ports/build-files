# Use latest LTS for ubuntu
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="chachoi@blackberry.com"
LABEL version="0.2.4"
LABEL description="Docker image for building projects for QNX."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Set locale
RUN apt-get clean && apt update && apt install -y locales software-properties-common
RUN locale-gen en_US en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

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
	texinfo \
	pkg-config \
	gfortran \
	vim \
	dos2unix \
	sassc \
	libglib2.0-bin \
	libglib2.0-dev \
	ninja-build \
	net-tools \
	tree \
	scons

# Install QT dependancies
RUN apt-get update && apt-get install -y \
	make \
	libclang-dev \
	clang \
	gcc \
	bison \
	gperf \
	sshpass \
	libfontconfig1-dev \
	libfreetype6-dev \
	xvfb \
	libx11-dev \
	libx11-xcb-dev \
	libxext-dev \
	libxfixes-dev \
	libxi-dev \
	libxrender-dev \
	libxcb1-dev \
	libxcb-glx0-dev \
	libxcb-keysyms1-dev \
	libxcb-image0-dev \
	libxcb-shm0-dev \
	libxcb-icccm4-dev \
	libxcb-sync-dev \
	libxcb-xfixes0-dev \
	libxcb-shape0-dev \
	libxcb-randr0-dev \
	libxcb-render-util0-dev \
	libxcb-util-dev \
	libxcb-xinerama0-dev \
	libxcb-xkb-dev \
	libxcb-cursor-dev \
	libxkbcommon-dev \
	libxkbcommon-x11-dev \
	libatspi2.0-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libtiff-dev \
	libjpeg-dev \
	libxml2-dev \
	libxslt1-dev \
	freeglut3-dev

# Install python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
	apt update && \
	apt-get install -y \
	python3.11-dev \
	python3.11-venv \
	python3.11-distutils \
	rename

# Install CMake 3.31.7
RUN cd /opt && sudo wget https://cmake.org/files/v3.31/cmake-3.31.7-linux-x86_64.sh && \
	sudo mkdir /opt/cmake-3.31.7-linux-x86_64 && \
	yes | sudo sh cmake-3.31.7-linux-x86_64.sh --prefix=/opt/cmake-3.31.7-linux-x86_64 --skip-license && \
	sudo ln -s /opt/cmake-3.31.7-linux-x86_64/bin/cmake /usr/local/bin/cmake

# Install APK dependencies
RUN apt-get install -y \
  busybox \
  pax-utils \
  libzstd-dev \
  meson \
  scdoc

# Copy apk patches
COPY "patches/apk-tools/*" "patches/abuild/*" /root/

# Install apk-tools
RUN cd ~ && \
  git clone https://github.com/alpinelinux/apk-tools.git && cd apk-tools && \
  git checkout 5ce64d14ead8ca1f2ee688c095390c8db0e5945c && \
  git apply ~/0001-qnx-POSIX-API-compat.patch && \
  git apply ~/0002-qnx-make-apk-s-internal-folders-SLQS-compatible.patch && \
  git apply ~/0003-qnx-7xx-doesn-t-have-memmem-add-one-from-git.patch && \
  meson setup ~/apk-tools/build ~/apk-tools -Dprefix=/usr/local -Dtests=disabled && \
  meson compile -C build && \
  sudo meson install -C build

# Install and patch abuild
RUN cd ~ && \
  git clone -b 3.15.0_rc2 https://github.com/alpinelinux/abuild.git && cd abuild && \
  git apply ~/0001-qnx-disable-features-not-used-by-QNX.patch && \
  git apply ~/0002-qnx-add-Standardized-Layout-for-QNX-System-suport.patch && \
  git apply ~/0003-qnx-busybox-location-for-ubuntu-debian-used-by-cross.patch && \
  git apply ~/0004-abuild-remove-ash-specific-chdir.patch && \
  make && sudo make install

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
	empy==3.3.4 \
	lark \
	lark-parser \
	Cython==0.29.35 \
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
	pytest \
	pybind11 \
	requests \
	meson==1.3.0

WORKDIR /home/${USER_NAME}

# Welcome Message
COPY --chown=${USER_NAME}:${GROUP_NAME} ".qnxbashrc" "/usr/local/qnx"
COPY --chown=${USER_NAME}:${GROUP_NAME} ".git-completion.bash" "/usr/local/qnx"
COPY --chown=${USER_NAME}:${GROUP_NAME} "welcome.sh" "/usr/local/qnx"

CMD /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
