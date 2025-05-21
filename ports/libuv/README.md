# libuv [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libuv.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libuv.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libev
make -C build-files/ports/libev install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/libuv.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build libev
make -C build-files/ports/libev install -j4
```

# How to Run Tests and Applications

**NOTE**: [QNX-E QSTI](https://gitlab.com/qnx/quick-start-images/raspberry-pi-qnx-8.0-quick-start-image) on RPi4 is used to perform the tests and report results.

```bash
export TARGET_IP=<target-ip-address-or-hostname>

# Move the test binaries to the target
scp $QNX_TARGET/aarch64le/usr/local/bin/libuv_tests qnxuser@$TARGET_IP:~/bin

# To run the tests
ssh qnxuser@$TARGET_IP

export PATH=$PATH:/data/home/qnxuser/bin

cd bin
mkdir test
mv fixtures test

./uv_run_tests_a
```

Known test failures

- Only two tests should fail:
  - ipc_tcp_connection fails with timeout
  - pipe_connect_to_file is a known failure being tracked internally
