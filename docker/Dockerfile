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
	scons \
	autogen

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

# Install packages needed for building WebRTC
RUN apt install -qq --assume-yes \
	alsa-topology-conf \
	alsa-ucm-conf \
	autopoint \
	binutils-aarch64-linux-gnu \
	binutils-arm-linux-gnueabihf \
	binutils-mips64el-linux-gnuabi64 \
	binutils-mipsel-linux-gnu \
	bsdextrautils \
	bzip2-doc \
	cdbs \
	comerr-dev \
	dbus-x11 \
	dctrl-tools \
	debhelper \
	debugedit \
	devscripts \
	dh-autoreconf \
	dh-strip-nondeterminism \
	dh-translations \
	diffstat \
	dput \
	dwz \
	elfutils \
	flex \
	fonts-lato \
	gettext \
	gettext-base \
	gir1.2-atk-1.0 \
	gir1.2-gdkpixbuf-2.0 \
	gir1.2-gtk-3.0 \
	gir1.2-gudev-1.0 \
	gir1.2-harfbuzz-0.0 \
	gir1.2-pango-1.0 \
	groff-base \
	i965-va-driver \
	intel-media-va-driver \
	intltool \
	intltool-debian \
	jq \
	keyboard-configuration \
	krb5-multidev \
	lib32z1 \
	libaliased-perl \
	libapt-pkg-perl \
	libarchive-cpio-perl \
	libarchive-zip-perl \
	libarray-intspan-perl \
	libasm1 \
	libasound2 \
	libasound2-data \
	libasound2-dev \
	libasyncns0 \
	libatk-bridge2.0-dev \
	libatk1.0-dev \
	libb-hooks-endofscope-perl \
	libb-hooks-op-check-perl \
	libbluetooth-dev \
	libbluetooth3 \
	libbrlapi-dev \
	libbrlapi0.8 \
	libbz2-dev \
	libcairo-script-interpreter2 \
	libcairo2-dev \
	libcap-dev \
	libcapture-tiny-perl \
	libcgi-fast-perl \
	libcgi-pm-perl \
	libcgi-session-perl \
	libclass-data-inheritable-perl \
	libclass-method-modifiers-perl \
	libclass-xsaccessor-perl \
	libcommon-sense-perl \
	libconfig-tiny-perl \
	libconst-fast-perl \
	libcontextual-return-perl \
	libcpanel-json-xs-perl \
	libcups2-dev \
	libcupsfilters-dev \
	libcupsfilters1 \
	libcupsimage2 \
	libcupsimage2-dev \
	libcurl4-gnutls-dev \
	libdata-dpath-perl \
	libdata-messagepack-perl \
	libdata-optlist-perl \
	libdata-validate-domain-perl \
	libdata-validate-ip-perl \
	libdata-validate-uri-perl \
	libdatrie-dev \
	libdbd-pg-perl \
	libdbi-perl \
	libdebhelper-perl \
	libdevel-callchecker-perl \
	libdevel-size-perl \
	libdevel-stacktrace-perl \
	libdistro-info-perl \
	libdrm-dev \
	libdynaloader-functions-perl \
	libegl1-mesa-dev \
	libelf-dev \
	libemail-address-xs-perl \
	libepoxy-dev \
	libevdev-dev \
	libevdev2 \
	libexception-class-perl \
	libexporter-tiny-perl \
	libfcgi-bin \
	libfcgi-perl \
	libfcgi0ldbl \
	libfile-basedir-perl \
	libfile-chdir-perl \
	libfile-dirlist-perl \
	libfile-find-rule-perl \
	libfile-homedir-perl \
	libfile-stripnondeterminism-perl \
	libfile-touch-perl \
	libfile-which-perl \
	libfl-dev \
	libfl2 \
	libflac8 \
	libfont-ttf-perl \
	libfreezethaw-perl \
	libfribidi-dev \
	libfsverity0 \
	libfuse2 \
	libgbm-dev \
	libgdk-pixbuf-2.0-dev \
	libgif7 \
	libgit-wrapper-perl \
	libgitlab-api-v4-perl \
	libgpgme11 \
	libgraphite2-dev \
	libgssrpc4 \
	libgtk-3-dev \
	libgudev-1.0-0 \
	libgudev-1.0-dev \
	libharfbuzz-dev \
	libharfbuzz-gobject0 \
	libharfbuzz-icu0 \
	libhash-fieldhash-perl \
	libhtml-html5-entities-perl \
	libhttp-tiny-multipart-perl \
	libid3tag0 \
	libigdgmm12 \
	libimlib2 \
	libimport-into-perl \
	libinput-bin \
	libinput-dev \
	libinput10 \
	libio-interactive-perl \
	libio-prompt-tiny-perl \
	libio-prompter-perl \
	libio-pty-perl \
	libio-string-perl \
	libipc-run-perl \
	libipc-run3-perl \
	libipc-system-simple-perl \
	libiterator-perl \
	libiterator-util-perl \
	libjq1 \
	libjson-maybexs-perl \
	libjson-perl \
	libjson-xs-perl \
	libkadm5clnt-mit12 \
	libkadm5srv-mit12 \
	libkdb5-10 \
	libkrb5-dev \
	liblist-compare-perl \
	liblist-moreutils-perl \
	liblist-moreutils-xs-perl \
	liblist-someutils-perl \
	liblist-someutils-xs-perl \
	liblist-utilsby-perl \
	liblog-any-adapter-screen-perl \
	liblog-any-perl \
	liblua5.3-0 \
	liblzo2-2 \
	libmail-sendmail-perl \
	libmarkdown2 \
	libmath-base85-perl \
	libmodule-implementation-perl \
	libmodule-runtime-perl \
	libmoo-perl \
	libmoox-aliases-perl \
	libmoox-struct-perl \
	libmouse-perl \
	libmtdev-dev \
	libmtdev1 \
	libnamespace-autoclean-perl \
	libnamespace-clean-perl \
	libnet-domain-tld-perl \
	libnet-ipv6addr-perl \
	libnet-netmask-perl \
	libnetaddr-ip-perl \
	libnspr4 \
	libnspr4-dev \
	libnss3 \
	libnss3-dev \
	libnumber-compare-perl \
	libobject-id-perl \
	libobrender32v5 \
	libobt2v5 \
	libogg0 \
	libonig5 \
	libopus0 \
	libpackage-stash-perl \
	libpackage-stash-xs-perl \
	libpam0g-dev \
	libpango1.0-dev \
	libpangoxft-1.0-0 \
	libparams-classify-perl \
	libparams-util-perl \
	libpath-iterator-rule-perl \
	libpath-tiny-perl \
	libpci-dev \
	libpci3 \
	libpciaccess-dev \
	libperlio-gzip-perl \
	libperlio-utf8-strict-perl \
	libpixman-1-dev \
	libpkgconf3 \
	libpod-constants-perl \
	libpod-parser-perl \
	libpq5 \
	libproc-processtable-perl \
	libpulse-dev \
	libpulse-mainloop-glib0 \
	libpulse0 \
	libre-engine-re2-perl \
	libre2-9 \
	libreadonly-perl \
	libref-util-perl \
	libref-util-xs-perl \
	libregexp-pattern-license-perl \
	libregexp-pattern-perl \
	librole-tiny-perl \
	librpm9 \
	librpmbuild9 \
	librpmio9 \
	librpmsign9 \
	libruby3.0 \
	libsctp-dev \
	libsctp1 \
	libsereal-decoder-perl \
	libsereal-encoder-perl \
	libset-intspan-perl \
	libset-scalar-perl \
	libsndfile1 \
	libsocket6-perl \
	libsort-versions-perl \
	libspeechd-dev \
	libspeechd2 \
	libsqlite3-dev \
	libstartup-notification0 \
	libstrictures-perl \
	libstring-copyright-perl \
	libstring-escape-perl \
	libstring-shellquote-perl \
	libsub-exporter-perl \
	libsub-exporter-progressive-perl \
	libsub-identify-perl \
	libsub-install-perl \
	libsub-name-perl \
	libsub-override-perl \
	libsub-quote-perl \
	libsyntax-keyword-try-perl \
	libsys-hostname-long-perl \
	libsystemd-dev \
	libterm-readkey-perl \
	libtext-glob-perl \
	libtext-levenshteinxs-perl \
	libtext-markdown-discount-perl \
	libtext-xslate-perl \
	libthai-dev \
	libtime-duration-perl \
	libtime-moment-perl \
	libtype-tiny-perl \
	libtype-tiny-xs-perl \
	libtypes-serialiser-perl \
	libuchardet0 \
	libudev-dev \
	libunicode-utf8-perl \
	libva-dev \
	libva-drm2 \
	libva-glx2 \
	libva-wayland2 \
	libva-x11-2 \
	libva2 \
	libvariable-magic-perl \
	libvorbis0a \
	libvorbisenc2 \
	libvulkan-dev \
	libvulkan1 \
	libwacom-bin \
	libwacom-common \
	libwacom-dev \
	libwacom9 \
	libwant-perl \
	libwayland-bin \
	libwayland-dev \
	libwayland-egl1-mesa \
	libxcomposite-dev \
	libxcursor-dev \
	libxcvt0 \
	libxdamage-dev \
	libxft-dev \
	libxft2 \
	libxinerama-dev \
	libxrandr-dev \
	libxs-parse-keyword-perl \
	libxshmfence-dev \
	libxss-dev \
	libxss1 \
	libxv1 \
	libxxf86dga1 \
	libyaml-libyaml-perl \
	licensecheck \
	lighttpd \
	lighttpd-mod-deflate \
	lighttpd-mod-openssl \
	lintian \
	lzip \
	lzop \
	man-db \
	mesa-common-dev \
	mesa-va-drivers \
	mesa-vulkan-drivers \
	obconf \
	openbox \
	p7zip \
	pango1.0-tools \
	patchutils \
	pci.ids \
	pkgconf \
	po-debconf \
	python3-certifi \
	python3-chardet \
	python3-debian \
	python3-gpg \
	python3-idna \
	python3-magic \
	python3-requests \
	python3-scour \
	python3-unidiff \
	python3-urllib3 \
	python3-xdg \
	rake \
	rpm \
	rpm-common \
	rpm2cpio \
	ruby \
	ruby-net-telnet \
	ruby-rubygems \
	ruby-webrick \
	ruby-xmlrpc \
	ruby3.0 \
	rubygems-integration \
	scour \
	scrot \
	spawn-fcgi \
	strace \
	systemd-hwe-hwdb \
	t1utils \
	udev \
	unzip \
	va-driver-all \
	wayland-protocols \
	wdiff \
	x11-utils \
	x11-xserver-utils \
	xcompmgr \
	xcvt \
	xserver-xorg-core \
	xserver-xorg-video-dummy \
	zip \
	zstd

# Install CMake 3.31.7
RUN cd /opt && sudo wget https://cmake.org/files/v3.31/cmake-3.31.7-linux-x86_64.sh && \
	sudo mkdir /opt/cmake-3.31.7-linux-x86_64 && \
	yes | sudo sh cmake-3.31.7-linux-x86_64.sh --prefix=/opt/cmake-3.31.7-linux-x86_64 --skip-license && \
	sudo ln -s /opt/cmake-3.31.7-linux-x86_64/bin/cmake /usr/local/bin/cmake && \
	sudo sed -i 's/gmake //' /opt/cmake-3.31.7-linux-x86_64/share/cmake-3.31/Modules/CMakeUnixFindMake.cmake && \
	sudo sed -i 's/gmake //' /usr/share/cmake-3.22/Modules/CMakeUnixFindMake.cmake

# Install APK dependencies (apk stuff is removed, but dependencies left intentionally)
RUN apt-get install -y \
  busybox \
  pax-utils \
  libzstd-dev \
  meson \
  scdoc

# Adding user
ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID

ENV PS1='[QNX] (\u) \w$ '

RUN groupadd --gid ${GROUP_ID} ${GROUP_NAME} && \
	useradd --uid ${USER_ID} --gid ${GROUP_ID} --groups sudo --no-log-init --create-home ${USER_NAME} && \
	echo "${USER_NAME}:password" | chpasswd

# Create a folder for python venv
RUN mkdir -p /usr/local/qnx
RUN chown ${USER_NAME} /usr/local/qnx
USER ${USER_NAME}

# Get depot tools
RUN cd /usr/local/qnx && \
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

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
	versioneer \
	meson==1.3.0

WORKDIR /home/${USER_NAME}

# Welcome Message
COPY --chown=${USER_NAME}:${GROUP_NAME} ".qnxbashrc" "/usr/local/qnx"
COPY --chown=${USER_NAME}:${GROUP_NAME} ".git-completion.bash" "/usr/local/qnx"
COPY --chown=${USER_NAME}:${GROUP_NAME} "welcome.sh" "/usr/local/qnx"

CMD /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
