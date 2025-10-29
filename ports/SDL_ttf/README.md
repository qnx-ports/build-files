# SDL_ttf [![Build](https://github.com/qnx-ports/build-files/actions/workflows/SDL_ttf.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/SDL_ttf.yml)

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

cd ~/qnx_workspace

# Clone SDL_ttf
git clone https://github.com/qnx-ports/SDL_ttf.git

# Build SDL_ttf
make -C build-files/ports/SDL_ttf JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/SDL_ttf.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
make -C build-files/ports/SDL_ttf JLEVEL=4 install
```
