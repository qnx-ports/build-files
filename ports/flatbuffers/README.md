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
git clone https://github.com/google/flatbuffers.git --branch v25.9.23

# Build flatbuffers
QNX_PROJECT_ROOT="$(pwd)/flatbuffers" make -C build-files/ports/flatbuffers JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/google/flatbuffers.git --branch v25.9.23

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build flatbuffers
QNX_PROJECT_ROOT="$(pwd)/flatbuffers" make -C build-files/ports/flatbuffers JLEVEL=4 install
```

# How to run tests

Test executables are built under the build folder and can be installed to
/data/home/qnxuser/bin on the target, but we don't currently verify them.
