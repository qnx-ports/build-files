# openvino [![Build](https://github.com/qnx-ports/build-files/actions/workflows/openvino.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/openvino.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

## PRE-REQUISITE
**NOTE**: An installation of google test on your **SDP** is required. Please follow the build instruction for `googletest` with `gmock` and make sure it is installed to the same SDP folder that you will source below.

Use `4` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=4` or `-j4`.

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

# Install git lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install git-lfs

# Clone protobuf
cd ~/qnx_workspace
git clone --recurse-submodules https://github.com/qnx-ports/protobuf.git

# Clone flatbuffers
git clone https://github.com/google/flatbuffers.git --branch v25.9.23

# Clone ComputeLibrary
git clone https://github.com/qnx-ports/ComputeLibrary.git

# Clone openvino
git clone https://github.com/qnx-ports/openvino.git

# Build protobuf
BUILD_SHARED_LIBS=OFF make -C build-files/ports/protobuf install JLEVEL=4

# Build flatbuffers
make -C build-files/ports/flatbuffers INSTALL_ROOT_linux="$(pwd)/build-files/ports/flatbuffers/host_flatc" USE_INSTALL_ROOT=true JLEVEL=4 install

# Build ComputeLibrary
BUILD_EXAMPLES=OFF BUILD_TESTING=OFF BUILD_SHARED_LIBS=OFF QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C build-files/ports/ComputeLibrary install -j4

# Build openvino
QNX_PROJECT_ROOT="$(pwd)/openvino" make -C build-files/ports/openvino JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/openvino.git
git clone --recurse-submodules https://github.com/qnx-ports/protobuf.git
git clone https://github.com/google/flatbuffers.git --branch v25.9.23
git clone https://github.com/qnx-ports/ComputeLibrary.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Install git lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install git-lfs

# Build protobuf
BUILD_SHARED_LIBS=OFF make -C build-files/ports/protobuf install JLEVEL=4

# Build flatbuffers
make -C build-files/ports/flatbuffers INSTALL_ROOT_linux="$(pwd)/build-files/ports/flatbuffers/host_flatc" USE_INSTALL_ROOT=true JLEVEL=4 install

# Build ComputeLibrary
BUILD_EXAMPLES=OFF BUILD_TESTING=OFF BUILD_SHARED_LIBS=OFF QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C build-files/ports/ComputeLibrary install -j4

# Build openvino
make -C build-files/ports/openvino JLEVEL=4 install
```

# How to run tests

Test executables are built under the build folder and can be installed to
/data/home/qnxuser/bin on the target, but we don't currently verify them.
