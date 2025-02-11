# graphite [![Build](https://github.com/qnx-ports/build-files/actions/workflows/graphite.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/graphite.yml)

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
git clone https://github.com/silnrsi/graphite.git

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone graphite
cd ~/qnx_workspace
# checkout to the latest stable
cd graphite
git checkout 1.3.14
cd ..

# Build graphite
QNX_PROJECT_ROOT="$(pwd)/graphite" JLEVEL=4 make -C build-files/ports/graphite install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/gr2fonttest* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libgraphite2* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin` or `~/lib` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are not avaliable.
