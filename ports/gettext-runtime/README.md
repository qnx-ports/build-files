# gettext-runtime [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gettext-runtime.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gettext-runtime.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly

## Feature notice
This package is placed as a supporting package for `cairo`, hence the build script does not contain a full feature gettext.

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.23.1.tar.gz && tar -xf gettext-0.23.1.tar.gz

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build gettext-runtime
QNX_PROJECT_ROOT="$(pwd)/gettext-0.23.1/gettext-runtime" JLEVEL=4 make -C build-files/ports/gettext-runtime install
```

# Deploy binaries via SSH
This port provides the all binaries obtained from QSC, but may be slightly more updated.
On top of that, `libasprintf` is also provided with some extra binaries.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/gettext* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/envsubst $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/ngettext $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libintl* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libasprintf* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib

# also need to deploy share datas
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/share/* $TARGET_USER@$TARGET_IP_ADDRESS:~/share
```

If some of the directories do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/share"
````

# Tests
Tests are not available.
