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
# how to run  tests for QNX

run the copy_and_setup_dlt_tests.sh from the host machine 
this will copy the  run_dlt_test_cases.sh to qnx target /data/home/qnxuser/tests path
run the script to execute the testcases.

Note:

ARCH variable  in  copy_and_setup_dlt_tests.sh  should selected as per the Target architecture.( "nto-x86_64-o" or "nto-aarch64-le")

QNX_USER="qnxuser"
QNX_IP="10.123.2.81"
QNX_PASSWORD="qnxuser"
TARGET_PATH="/data/home/qnxuser/tests"

modify the above variables as per your target and requirements.