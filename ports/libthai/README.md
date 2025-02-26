# libthai [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libthai.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libthai.yml)

Supports QNX7.1 and QNX8.0

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Dependency warning

You should compile and install its dependencies before proceed.
+ [`libdatrie`](https://github.com/qnx-ports/build-files/tree/main/ports/libdatrie)

A convenience script `install_all.sh` is provided for easy installation of all required dependencies, execute it just like a regular installation and set INSTALL_ROOT and JLEVEL.
To use the convenience script, please clone the entire `build-files` repository first. 
This convenience script will call `install_all.sh` inside dependencies recursively.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
wget https://github.com/tlwg/libthai/releases/download/v0.2.13/libthai-0.1.29.tar.xz && tar -xf libthai-0.1.29.tar.xz

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Optionally use the convenience script to install all dependencies
./build-files/ports/libthai/install_all.sh

# Build libthai
QNX_PROJECT_ROOT="$(pwd)/libthai-0.1.29" JLEVEL=4 make -C build-files/ports/libthai install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libthai* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib

# This is nessary
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/share/libthai* $TARGET_USER@$TARGET_IP_ADDRESS:~/share
```

If the `~/share` or `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/share"
````

# Tests
Tests are available, but currently there are no easy ways to run them on a QNX target system. Therefore the results will be provided instead in `tests.result`
Currently all tests are passed.
