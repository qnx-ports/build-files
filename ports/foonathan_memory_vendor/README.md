# foonathan_memory_vendor [![Build](https://github.com/qnx-ports/build-files/actions/workflows/foonathan_memory_vendor.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/foonathan_memory_vendor.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system
Supports QNX7.1 and QNX8.0

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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

# Clone foonathan_memory_vendor
git clone -b v1.3.1 https://github.com/eProsima/foonathan_memory_vendor.git

# Build foonathan_memory_vendor, set INSTALL_ROOT to choose the installation destination
QNX_PROJECT_ROOT="$(pwd)/foonathan_memory_vendor" make -C build-files/ports/foonathan_memory_vendor/ INSTALL_ROOT=<staging-install-folder> install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b v1.3.1 https://github.com/eProsima/foonathan_memory_vendor.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build foonathan_memory_vendor, set INSTALL_ROOT to choose the installation destination
QNX_PROJECT_ROOT="$(pwd)/foonathan_memory_vendor" make -C build-files/ports/foonathan_memory_vendor/ INSTALL_ROOT=<staging-install-folder> install -j4
```

# Tests
Tests not available.