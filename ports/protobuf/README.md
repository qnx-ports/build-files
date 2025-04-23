# protobuf [![Build](https://github.com/qnx-ports/build-files/actions/workflows/protobuf.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/protobuf.yml)

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
make -C build-files/ports/protobuf install JLEVEL=4 #[INSTALL_ROOT_nto=PATH_TO_YOUR_STAGING_AREA USE_INSTALL_ROOT=true]

# Build older version of protobuf
#QNX_PROJECT_ROOT=$(pwd)/protobuf/cmake make -C build-files/ports/protobuf install JLEVEL=4
```
