# sleef [![sleef](https://github.com/qnx-ports/build-files/actions/workflows/sleef.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/sleef.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone sleef
cd ~/qnx_workspace
git clone https://github.com/shibatch/sleef.git
git checkout 90ae01e5c71e378229ce0b2960a8e95dc89b9f17

# Build sleef
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/sleef" make -C build-files/ports/sleef install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
git clone https://github.com/shibatch/sleef.git
git checkout 90ae01e5c71e378229ce0b2960a8e95dc89b9f17

# Build sleef
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/sleef" make -C build-files/ports/sleef install -j4
```
