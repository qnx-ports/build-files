# flatbuffers [![Build](https://github.com/qnx-ports/build-files/actions/workflows/flatbuffers.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/flatbuffers.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

## PRE-REQUISITE
**NOTE**: An installation of google test on your **SDP** is required. Please follow the build instruction for `googletest` with `gmock` and make sure it is installed to the same SDP folder that you will source below.

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

# Clone flatbuffers
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/flatbuffers.git --branch qnx-v25.9.23

# Build flatbuffers
QNX_PROJECT_ROOT="$(pwd)/flatbuffers" BUILD_TESTING=ON make -C build-files/ports/flatbuffers JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/flatbuffers.git --branch qnx-v25.9.23

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build flatbuffers
QNX_PROJECT_ROOT="$(pwd)/flatbuffers" BUILD_TESTING=ON make -C build-files/ports/flatbuffers JLEVEL=4 install
```

# How to run tests

Copy tests and runtime dependencies to the target
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp -r ~/qnx_workspace/flatbuffers/tests qnxuser@$TARGET_HOST:/data/home/qnxuser

(cd ~/qnx_workspace/build-files/ports/flatbuffers/nto-aarch64-le/build && scp flatc flatsamplebfbs flatsamplebinary flatsampletext flattests  qnxuser@$TARGET_HOST:~/bin)
scp $QNX_TARGET/aarch64le/usr/local/lib/libflatbuffers.so* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

Run the tests on the target
```bash
ssh qnxuser:$TARGET_HOST

flattests
```
