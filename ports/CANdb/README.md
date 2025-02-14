# Catch2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/CANdb.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/CANdb.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
```

# Clone CANdb repository from tested release version
```bash
git clone https://github.com/qnx-ports/CANdb.git
```

# Or clone it from original repository
```bash
git clone https://github.com/GENIVI/CANdb.git
```

# Update 3rdParty dependencies
```bash
cd CANdb
git submodule update --init --recursive
cd -
```

# Setup a Docker container

Pre-requisite:

* Install Docker on Ubuntu 
  - https://docs.docker.com/engine/install/ubuntu/
* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)
  - https://www.qnx.com/products/everywhere/ (**Non-Commercial Use**)

```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Compile the port for QNX

This project is intended to be included in the build tree
and should be built along with the rest of the source files.
Therefore, only tests are built and installed here.

```bash
cd ~/qnx_workspace
# Build and install it in sysroot (QNX SDP)
make -C build-files/ports/CANdb install JLEVEL=$(nproc)
# Or build and install it in a staging area
make -C build-files/ports/CANdb install JLEVEL=$(nproc) INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA> USE_INSTALL_ROOT=true
```

# How to run tests

Copy(scp) tests to the target.
```bash
cd ~/qnx_workspace

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# copy test binaries to your QNX target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/CANdb_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
# or
scp -r $QNX_TARGET/x86_64/usr/local/bin/CANdb_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
cd /data/home/qnxuser/CANdb_tests/
./base_testsuite.sh
```

**Note**: All tests have to return no error.

```bash
...
==========================================
Tests suites summary for CANdb
==========================================
# TOTAL: 5
# PASS: 5
# FAIL: 0
==========================================
```
