
# bash [![Build](https://github.com/qnx-ports/build-files/actions/workflows/bash.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/bash.yml)

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

# Clone bash
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/bash.git

# Build bash
QNX_PROJECT_ROOT="$(pwd)/bash" make -C build-files/ports/bash install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/bash.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build bash
QNX_PROJECT_ROOT="$(pwd)/bash" make -C build-files/ports/bash install -j4
```

bash will be installed to `$QNX_TARGET/$CPUVARDIR/usr/local/bin/bash`.
