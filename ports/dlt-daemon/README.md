# dlt-daemon [![Build](https://github.com/qnx-ports/build-files/actions/workflows/dlt-daemon.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/dlt-daemon.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use the maximum number of cores to build this project.

# Setup a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Clone dlt-daemon
cd ~/qnx_workspace
git clone --recurse-submodules https://github.com/qnx-ports/dlt-daemon.git
```

# Or setup Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone --recurse-submodules https://github.com/qnx-ports/dlt-daemon.git
```

# Compile dlt-daemon and its tests for QNX
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
# Build dlt-daemon
BUILD_TESTING="ON" make -C build-files/ports/dlt-daemon install JLEVEL=$(nproc) [INSTALL_ROOT_nto=PATH_TO_YOUR_STAGING_AREA USE_INSTALL_ROOT=true]
```
# How to run tests

Copy(scp) tests to the target.

```bash
cd ~/qnx_workspace

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# copy test binaries to your QNX target
scp  $QNX_TARGET/x86_64/usr/local/lib/libgtest* qnxuser@$TARGET_HOST:/data/home/qnxuser/
# or
scp -r $QNX_TARGET/x86_64/usr/local/bin/dlt_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/
# copy test binaries to your QNX target
scp   $QNX_TARGET/x86_64/usr/local/lib/libdlt*  qnxuser@$TARGET_HOST:/data/home/qnxuser/
# copy script to run the tests
scp test_script.sh  qnxuser@$TARGET_HOST:/data/home/qnxuser/dlt_tests

```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
cd /data/home/qnxuser/CANdb_tests/
./test_script.sh

# test results (x86 VM)
13 test suites executed: 10 passed, 3 reported failures — gtest_dlt_user  (1/170  intermittent), gtest_dlt_daemon_gateway (1/46, intermittent), and  gtest_dlt_daemon_event_handler (1/25, coded FD 100 is not a valid open descriptor in the test context).

```