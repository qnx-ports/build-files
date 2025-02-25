# libffi [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libffi.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libffi.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly

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

# Clone libffi
cd ~/qnx_workspace
git clone https://github.com/libffi/libffi.git

# check out to v3.2.1
cd libffi
git checkout v3.2.1
cd ..

# Build libffi
QNX_PROJECT_ROOT="$(pwd)/libffi" JLEVEL=4 make -C build-files/ports/libffi install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/libffi/libffi.git

# check libffi out to v3.2.1
cd libffi
git checkout v3.2.1
cd ..

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build libffi
QNX_PROJECT_ROOT="$(pwd)/libffi" JLEVEL=4 make -C build-files/ports/libffi install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libffi* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If `~/lib` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are not avaliable.
