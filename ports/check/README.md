# check [![Build](https://github.com/qnx-ports/build-files/actions/workflows/check.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/check.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use the maximum number of cores to build this project.

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

# Clone check
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/check.git

# Build check
make -C build-files/ports/check install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd qnx_workspace
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/check.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build check
make -C build-files/ports/check install JLEVEL=4
```
