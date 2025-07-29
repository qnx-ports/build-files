# libev [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libev.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libev.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

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

# Clone libev
git clone https://github.com/qnx-ports/libev.git

# Build libev
make -C build-files/ports/libev install
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/libev.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build libev
make -C build-files/ports/libev install
```

### **NOTE**: Tests are not available
