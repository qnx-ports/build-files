# bzip2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/bzip2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/bzip2.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly.

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/libarchive/bzip2.git

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone bzip2
cd ~/qnx_workspace
# checkout to the latest stable
cd bzip2
git checkout bzip2-1.0.8
cd ..

# Build bzip2
QNX_PROJECT_ROOT="$(pwd)/bzip2" JLEVEL=4 make -C build-files/ports/bzip2 install
```

# Deploy binaries via SSH
This library is purely static, therefore there is no need to deploy any share objects. However in addition to what QSC offers, some extra command line tools are available here
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/bunzip $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/bz* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
```

If the `~/bin` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
````

# Tests
Tests are not avaliable.
