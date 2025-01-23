# lely-core [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lely-core.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lely-core.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/lely-core.git
```

# Generate GNU build tool ./configure and all needed Makefiles
```bash
cd lely-core
autoreconf -i
cd -
```

# Setup a Docker container

Pre-requisite:

* Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)

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
```bash
cd ~/qnx_workspace
# Build lely-core and install it in sysroot (QNX SDP)
make -C build-files/ports/lely-core install JLEVEL=$(nproc)
# Or build lely-core and install it in a staging area
make -C build-files/ports/lely-core install JLEVEL=$(nproc) INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA> USE_INSTALL_ROOT=true
```

# Compile ECSS (https://ecss.nl/) compliant port

Build and install ECSS compliant port just need to have variable ECSS=on
```bash
cd ~/qnx_workspace
# Build lely-core ECSS (https://ecss.nl/) compliant port
make -C build-files/ports/lely-core install JLEVEL=$(nproc) ECSS=on
```

# How to run tests

Build lely-core test and scp it to the target.
```bash
cd ~/qnx_workspace
# Build lely-core test and install it in sysroot (QNX SDP)
make -C build-files/ports/lely-core check JLEVEL=$(nproc)

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# copy lely-core test binaries to your QNX target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/lely-core_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
# or
scp -r $QNX_TARGET/x86_64/usr/local/bin/lely-core_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run lely-core tests
cd /data/home/qnxuser/lely-core_tests/
./run_testsuites.sh
```

**Note**: All tests have to return no error.

```bash
...
==========================================
Tests summary for lely-core 3.2.0
==========================================
# TOTAL: 8
# PASS: 8
# FAIL: 0
==========================================
```
