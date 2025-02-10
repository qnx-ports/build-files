# libiconv [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libiconv.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libiconv.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.18.tar.gz && tar -xf libiconv-1.18.tar.gz

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build libiconv
QNX_PROJECT_ROOT="$(pwd)/libiconv-1.18" JLEVEL=4 make -C build-files/ports/libiconv install
```

# Deploy binaries via SSH
This port provides the same binaries obtained from QSC, but may be slightly more updated. On top of that, `libcharset` and `iconv` are also provided.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/iconv* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/libiconv* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/libcharset* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin` or `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are not available.
