# protobuf [![Build](https://github.com/qnx-ports/build-files/actions/workflows/protobuf.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/protobuf.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Setup a Docker container

Pre-requisite:

* Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Clone protobuf
cd ~/qnx_workspace
git clone --recurse-submodules https://github.com/qnx-ports/protobuf.git
# Older version of protobuf
#git clone --recurse-submodules https://github.com/qnx-ports/protobuf.git -b qnx-v3.15.0
```

# Or setup Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone --recurse-submodules https://github.com/qnx-ports/protobuf.git
# Older version of protobuf
#git clone --recurse-submodules https://github.com/qnx-ports/protobuf.git -b qnx-v3.15.0
```

# Compile protobuf and its tests for QNX
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
# Build protobuf
make -C build-files/ports/protobuf install JLEVEL=$(nproc) #[INSTALL_ROOT_nto=PATH_TO_YOUR_STAGING_AREA USE_INSTALL_ROOT=true]

# Build older version of protobuf
#QNX_PROJECT_ROOT=$(pwd)/protobuf/cmake make -C build-files/ports/protobuf install JLEVEL=$(nproc)
```

# How to run tests
Build tests and scp it to the target.

**IMPORTANT** protobuf needs **memory** > 8Gb **space** > 500Mb on data partition and **inodes** > 20k
### For example: mkqnximage --type=qemu --arch=x86_64 --clean --run --force --ram=8G --data-size=500 --data-inodes=20000
```bash
cd ~/qnx_workspace
# Build protobuf and all tests
make -C build-files/ports/protobuf JLEVEL=$(nproc)

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf protobuf_tests"

# create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir protobuf_tests"

# copy all sources needed for test execution
scp -r protobuf/src qnxuser@$TARGET_HOST:/data/home/qnxuser/protobuf_tests/

# collect all binaries for testing
# for aarch64
PROTOBUF_TEST_BINS=$(find build-files/ports/protobuf/nto-aarch64-le/protobuf -maxdepth 1  -type f,l  -executable)
# or for x86_64
PROTOBUF_TEST_BINS=$(find build-files/ports/protobuf/nto-x86_64-o/protobuf -maxdepth 1  -type f,l  -executable)

# copy all binaries to your QNX target
scp -r $PROTOBUF_TEST_BINS qnxuser@$TARGET_HOST:/data/home/qnxuser/protobuf_tests/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# setup protobuf env
cd /data/home/qnxuser/protobuf_tests
export PATH=$(pwd):$PATH
export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH

# IMPORTANT: if /tmp folder is not existing/readonly/<not enough space>, please use
# export TEST_TMPDIR=<path to your own temp folder>

# run protobuf tests
./tests
```

**Note**: Some tests are failed due to QNX float to string.
```bash
[----------] Global test environment tear-down
[==========] 2364 tests from 209 test suites ran. (26098 ms total)
[  PASSED  ] 2359 tests.
[  SKIPPED ] 1 test, listed below:
[  SKIPPED ] ArenaTest.SpaceReusePoisonsAndUnpoisonsMemory
[  FAILED  ] 4 tests, listed below:
[  FAILED  ] MiscTest.DefaultValues
[  FAILED  ] TextFormatTest.PrintFloatPrecision
[  FAILED  ] TextFormatTest.ParseExotic
[  FAILED  ] TextFormatTest.PrintFieldsInIndexOrder

 4 FAILED TESTS
```
