# zlib [![Build](https://github.com/qnx-ports/build-files/actions/workflows/zlib.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/zlib.yml)

Supports QNX7.1 and QNX8.0

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone zlib
cd ~/qnx_workspace
git clone https://github.com/madler/zlib.git
# checkout to the latest stable
cd zlib
git checkout v1.3.1
cd ..

# Build zlib
QNX_PROJECT_ROOT="$(pwd)/zlib" JLEVEL=4 make -C build-files/ports/zlib install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/madler/zlib.git
# checkout to the latest stable
cd zlib
git checkout v1.3.1
cd ..

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build zlib
QNX_PROJECT_ROOT="$(pwd)/zlib" JLEVEL=4 make -C build-files/ports/zlib install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libz* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/lib` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are avaliable; currently all tests are passed.

To run tests, make sure you have already deployed required binaries metioned above and excute the following.
```base
scp ./build-files/ports/zlib/nto-aarch64-le/build/example* $TARGET_USER@$TARGET_IP_ADDRESS:~
scp ./build-files/ports/zlib/nto-aarch64-le/build/minigzip* $TARGET_USER@$TARGET_IP_ADDRESS:~

# On your target system, navigate to ~, excute the following commands to run tests
./example
./example64
./minigzip
./minigzip64

```
