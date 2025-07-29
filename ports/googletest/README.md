# GoogleTest [![Build](https://github.com/qnx-ports/build-files/actions/workflows/googletest.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/googletest.yml)

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone googletest
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/googletest.git

# Build googletest
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/googletest.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4
```

# How to run tests

scp libraries and tests to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp -r $QNX_TARGET/aarch64le/usr/local/bin/googletest_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp $QNX_TARGET/aarch64le/usr/local/lib/libg* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```
Run tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run unit tests
cd /data/home/qnxuser/bin/googletest_tests
chmod +x *
./gmock-actions_test
```
