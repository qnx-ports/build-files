# pistache [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pistache.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pistache.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

## Dependencies
- libevent
- googletest (for testing)
- libcurl (for testing)

**NOTE**: Pistache uses pkg-config to locate its dependencies. Ensure that the *.pc files are installed and that the paths defined in those files are correct.

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

# Clone pistache
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/pistache.git

# Build and install pistache
[PISTACHE_BUILD_TESTS=true] make -C build-files/ports/pistache install JLEVEL=$(nproc)
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/pistache.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build and install pistache
[PISTACHE_BUILD_TESTS=true] make -C build-files/ports/pistache install JLEVEL=$(nproc)
```
