# dlt-daemon [![Build](https://github.com/qnx-ports/build-files/actions/workflows/dlt-daemon.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/dlt-daemon.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

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

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Compile dlt-daemon and its tests for QNX
```bash
# installation in the sysroot (QNX SDP):
BUILD_TESTING="ON" make -C build-files/ports/dlt-daemon install JLEVEL=$(nproc)
# or installation in a staging area:
BUILD_TESTING="ON" make -C build-files/ports/dlt-daemon install JLEVEL=$(nproc) [INSTALL_ROOT_nto=PATH_TO_YOUR_STAGING_AREA USE_INSTALL_ROOT=true]
```
