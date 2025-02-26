# shared-mime-info [![Build](https://github.com/qnx-ports/build-files/actions/workflows/shared-mime-info.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/shared-mime-info.yml)

Supports both QNX 8.0 and QNX 7.1

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

# Clone shared-mime-info
cd ~/qnx_workspace
git clone https://gitlab.gnome.org/GNOME/shared-mime-info.git

# checkout to the latest stable
cd shared-mime-info
git checkout 2.4
cd ..

# Build shared-mime-info
QNX_PROJECT_ROOT="$(pwd)/shared-mime-info" JLEVEL=4 make -C build-files/ports/shared-mime-info install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://gitlab.freedesktop.org/xdg/shared-mime-info.git

# checkout to the latest stable
cd shared-mime-info
git checkout 2.4
cd ..

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build shared-mime-info
QNX_PROJECT_ROOT="$(pwd)/shared-mime-info" JLEVEL=4 make -C build-files/ports/shared-mime-info install
```

# Deploy binaries via SSH
This libraries is just a collection of locale files
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r $QNX_TARGET/aarch64le/usr/local/share $TARGET_USER@$TARGET_IP_ADDRESS:~
```

# Tests
Tests are not available.