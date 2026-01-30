# libsndfile [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libsndfile.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libsndfile.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true with the build command.

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

# Clone latest stable version libsndfile
git clone -b 1.2.2 https://github.com/libsndfile/libsndfile.git

# Build libsndfile
QNX_PROJECT_ROOT="$(pwd)/libsndfile" make -C build-files/ports/libsndfile/ install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b 1.2.2 https://github.com/libsndfile/libsndfile.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build libsndfile
QNX_PROJECT_ROOT="$(pwd)/libsndfile" make -C build-files/ports/libsndfile/ install -j4
```
