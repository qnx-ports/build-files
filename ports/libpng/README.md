# libpng [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libpng.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libpng.yml)

Supports QNX7.1 and QNX8.0

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Dependency warning

You should compile and install its dependencies to your QNX SDP before proceed.
+ [`zlib`](https://github.com/qnx-ports/build-files/tree/main/ports/zlib)

A convenient script is also provided for automatic compile and install dependencies.

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

# Clone libpng
cd ~/qnx_workspace
git clone https://github.com/pnggroup/libpng.git

# checkout to the latest stable
cd libpng
git checkout v1.6.46
cd ..

# Build libpng
QNX_PROJECT_ROOT="$(pwd)/libpng" JLEVEL=4 make -C build-files/ports/libpng install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/pnggroup/libpng.git

# checkout to the latest stable
cd libpng
git checkout v1.6.46
cd ..

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build libpng
QNX_PROJECT_ROOT="$(pwd)/libpng" JLEVEL=4 make -C build-files/ports/libpng install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r $QNX_TARGET/aarch64le/usr/local/bin/libpng* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r $QNX_TARGET/aarch64le/usr/local/bin/png* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libpng* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If `~/lib` or `~bin` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are avaliable; currently all tests are passed.

To run tests, make sure you have already deployed required binaries metioned above and excute the following.
```base
scp ./build-files/ports/libpng/nto-aarch64-le/build/pngtest $TARGET_USER@$TARGET_IP_ADDRESS:~
scp ./build-files/ports/libpng/nto-aarch64-le/build/pngstest $TARGET_USER@$TARGET_IP_ADDRESS:~
# copy the test image as well
scp ./libpng/pngtest.png $TARGET_USER@$TARGET_IP_ADDRESS:~


# On your target system, navigate to ~, excute the following command to run all tests
sh ./pngtest
sh ./pngstest

```