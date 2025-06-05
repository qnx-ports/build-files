**NOTE**: QNX ports are only supported from a Linux host operating system
**NOTE**: ntttcp-for-linux we are porting till commit/b483afe00b9b095e8bf56c01308d81aeae0cb53c, last official release was on 2019. so after that there are no official releases but resolved few major security issues

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone ntttcp-for-linux
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/ntttcp-for-linux.git

# Build ntttcp-for-linux
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/ntttcp-for-linux/src" make -C build-files/ports/ntttcp install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/ntttcp-for-linux.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build ntttcp-for-linux
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/ntttcp-for-linux/src" make -C build-files/ports/ntttcp install -j4
```
