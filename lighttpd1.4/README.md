**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Build the Docker image and create a container
git clone https://gitlab.com/qnx/ports/docker-build-environment.git && cd docker-build-environment
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone ComputeLibrary
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/lighttpd1.4.git

# Build and install lighttpd binaries to SDP
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) make -C build-files/lighttpd1.4  install
```

# Compile the port for QNX on Ubuntu host

## Install dependencies

```bash
sudo apt install automake pkg-config libtool
```

## Generate GNU build tool ./configure and all needed Makefiles

```bash
cd lighttpd1.4
./autogen.sh
cd -
````

## Setup QNX SDP environment

```bash
source <path-to-sdp>/qnxsdp-env.sh
```

## Build and install lighttpd binaries to SDP

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) make -C build-files/lighttpd1.4  install
```

**All binary files have to be installed to SDP**

* $QNX_TARGET/x86_64/usr/local/lib/mod_*.so
* $QNX_TARGET/x86_64/usr/local/sbin/lighttpd
* $QNX_TARGET/x86_64/usr/local/sbin/lighttpd-angel
* $QNX_TARGET/aarch64le/usr/local/lib/mod_*.so
* $QNX_TARGET/aarch64le/usr/local/sbin/lighttpd
* $QNX_TARGET/aarch64le/usr/local/sbin/lighttpd-angel

## Build and install lighttpd binaries to specific path

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=$(nproc) make -C build-files/lighttpd1.4  install USE_INSTALL_ROOT=true INSTALL_ROOT_nto=<full-path>
```

**All binary files have to be installed to specific path**

* \<full-path\>/x86_64/usr/local/lib/mod_*.so
* \<full-path\>/x86_64/usr/local/sbin/lighttpd
* \<full-path\>/x86_64/usr/local/sbin/lighttpd-angel
* \<full-path\>/aarch64le/usr/local/lib/mod_*.so
* \<full-path\>/aarch64le/usr/local/sbin/lighttpd
* \<full-path\>/aarch64le/usr/local/sbin/lighttpd-angel
