# restbed [![Build](https://github.com/qnx-ports/build-files/actions/workflows/restbed.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/restbed.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
#TODO
#git clone https://github.com/qnx-ports/build-files.git
#git clone https://github.com/qnx-ports/restbed.git
```

# Update 3rdParty dependencies
```bash
cd restbed
git submodule update --init --recursive
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
# Build restbed and install it in sysroot (QNX SDP)
make -C build-files/ports/restbed install JLEVEL=$(nproc)
# Or build restbed and install it in a staging area
make -C build-files/ports/restbed install JLEVEL=$(nproc) INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA> USE_INSTALL_ROOT=true
```

# How to run tests

Build restbed test and scp it to the target.

**IMPORTANT** restbed build tree needs **space** > 500Mb on data partition and **inodes** > 20k
### For example: mkqnximage --type=qemu --arch=x86_64 --clean --run --force --data-size=500 --data-inodes=20000

```bash
cd ~/qnx_workspace
# Build restbed and all tests
make -C build-files/ports/restbed check JLEVEL=$(nproc)

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf restbed_tests"

# create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir restbed_tests"

# copy restbed build tree to your QNX target
scp -r build-files/ports/restbed/nto-aarch64-le/build/* qnxuser@$TARGET_HOST:/data/home/qnxuser/restbed_tests/
# or
scp -r build-files/ports/restbed/nto-x86_64-o/build/* qnxuser@$TARGET_HOST:/data/home/qnxuser/restbed_tests/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run restbed tests
cd /data/home/qnxuser/restbed_tests/
python ./base_testsuite.py
```

**Note**: All tests have to return no error.

```bash
...
======================================================
Tests suites summary for Restbed 4.8
======================================================
# test/unit        - ALL:10 PASS:10 FAIL:0 SKIP:0 [0:00:00.115737]
# test/feature     - ALL:65 PASS:65 FAIL:0 SKIP:0 [0:00:14.513149]
# test/regression  - ALL:31 PASS:31 FAIL:0 SKIP:0 [0:00:08.603444]
# test/integration - ALL:10 PASS:10 FAIL:0 SKIP:0 [0:00:00.114280]
# TOTAL: 116 [0:00:23.346610]
# PASS: 116
# FAIL: 0
# SKIP: 0
======================================================
```
