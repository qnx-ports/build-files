# libdatrie [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libdatrie.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libdatrie.yml)

Supports QNX7.1 and QNX8.0

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
wget https://github.com/tlwg/libdatrie/releases/download/v0.2.13/libdatrie-0.2.13.tar.xz && tar -xf libdatrie-0.2.13.tar.xz

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build libdatrie
QNX_PROJECT_ROOT="$(pwd)/libdatrie-0.2.13" JLEVEL=4 make -C build-files/ports/libdatrie install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/trie* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/libdatrie* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin` or `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are available, but currently there is no easy way to run them on a QNX target system. Therefore the results will be provided instead in `tests.result`
Currently all tests are passed.
