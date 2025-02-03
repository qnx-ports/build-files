# Catch2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/Catch2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/Catch2.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/Catch2.git
```

# Regenerate the amalgamated distribution (some tests are built against it)
```bash
./tools/scripts/generateAmalgamatedFiles.py
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
# Build Catch2 and install it in sysroot (QNX SDP)
make -C build-files/ports/Catch2 install JLEVEL=$(nproc)
# Or build Catch2 and install it in a staging area
make -C build-files/ports/Catch2 install JLEVEL=$(nproc) INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA> USE_INSTALL_ROOT=true
```

# How to run tests

Build Catch2 test and scp it to the target.
```bash
cd ~/qnx_workspace

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# copy Catch2 test binaries to your QNX target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/Catch2_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
# or
scp -r $QNX_TARGET/x86_64/usr/local/bin/Catch2_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run Catch2 tests
cd /data/home/qnxuser/Catch2_tests/
python ./base_testsuite.py
```

**Note**: All tests have to return no error.

```bash
...
======================================================
Tests suites summary for Catch2 3.6.0
======================================================
# MAIN  Tests - ALL:76 PASS:68 FAIL:0 SKIP:8 [0:00:11.233883]
# EXTRA Tests - ALL:41 PASS:35 FAIL:0 SKIP:6 [0:00:07.610188]
# TOTAL: 117 [0:00:18.844071]
# PASS: 103
# FAIL: 0
# SKIP: 14
======================================================
```
