# libssh2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libssh2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libssh2.yml)

# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone libssh2
git clone https://github.com/qnx-ports/libssh2.git
cd libssh2
git checkout qnx-libssh2-1.11.1
cd ..


# Build libssh2
QNX_PROJECT_ROOT="$(pwd)/libssh2" make -C build-files/ports/libssh2/  install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone libssh2
git clone https://github.com/qnx-ports/libssh2.git
cd libssh2
git checkout qnx-release-1.24.1
cd ..


# Build libssh2
QNX_PROJECT_ROOT="$(pwd)/libssh2" make -C build-files/ports/libssh2/  install -j4
```

