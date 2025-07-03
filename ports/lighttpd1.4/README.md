# lighttpd1.4 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lighttpd1.4.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lighttpd1.4.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone lighttpd1.4
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/lighttpd1.4.git
```

## Generate GNU build tool ./configure and all needed Makefiles

```bash
cd lighttpd1.4
./autogen.sh
cd -
```

## Build and install lighttpd binaries to SDP

```bash
# Build and install lighttpd binaries to SDP
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=4 make -C build-files/ports/lighttpd1.4  install
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
```

## Setup QNX SDP environment

```bash
source <path-to-sdp>/qnxsdp-env.sh
```

## Build and install lighttpd binaries to SDP

```bash
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=4 make -C build-files/ports/lighttpd1.4  install
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
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=4 make -C build-files/ports/lighttpd1.4  install USE_INSTALL_ROOT=true INSTALL_ROOT_nto=<full-path>
```

**All binary files have to be installed to specific path**

* \<full-path\>/x86_64/usr/local/lib/mod_*.so
* \<full-path\>/x86_64/usr/local/sbin/lighttpd
* \<full-path\>/x86_64/usr/local/sbin/lighttpd-angel
* \<full-path\>/aarch64le/usr/local/lib/mod_*.so
* \<full-path\>/aarch64le/usr/local/sbin/lighttpd
* \<full-path\>/aarch64le/usr/local/sbin/lighttpd-angel

## Test instruction

Pre-requisite

  - build and install perl5 to the sdp: https://github.com/qnx-ports/build-files/blob/main/ports/perl5/README.md

Build and install tests to SDP.
```bash
cd ~/qnx_workspace
# Build and install all tests
QNX_PROJECT_ROOT="$(pwd)/lighttpd1.4" JLEVEL=4 make -C build-files/ports/lighttpd1.4 check
```

**IMPORTANT** before testing you have to properly install perl to the target

  - For example: mkqnximage --type=qemu --arch=x86_64 --clean --run --force --data-size=500 --data-inodes=20000 --perl=yes

Run tests on the target.
```bash
# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# copy installed tests to your QNX target
scp -r  $QNX_TARGET/x86_64/usr/local/bin/lighttpd_tests root@$TARGET_HOST:/data/home/root/

# or
scp -r  $QNX_TARGET/x86_64/usr/local/bin/lighttpd_tests root@$TARGET_HOST:/data/home/root/

# ssh into the target
ssh root@$TARGET_HOST

# run tests
cd /data/home/root/lighttpd_tests

./base_testsuite.sh
```

**Note**: All tests have to return no error.

```bash
All tests successful.
Files=4, Tests=221,  1 wallclock secs ( 0.03 usr  0.00 sys +  0.43 cusr  0.00 csys =  0.46 CPU)
Result: PASS
PASS:tests/cleanup.sh
cleaning up
==========================================
Perl tests summary for lighttpd 1.4.73
==========================================
# TOTAL: 3
# PASS: 3
# FAIL: 0
==========================================
```
