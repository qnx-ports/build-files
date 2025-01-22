# csmith [![Build](https://github.com/qnx-ports/build-files/actions/workflows/csmith.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/csmith.yml)

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

# Clone csmith
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/csmith.git

# Build csmith
QNX_PROJECT_ROOT="$(pwd)/csmith" make -C build-files/ports/csmith install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/csmith.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build csmith
QNX_PROJECT_ROOT="$(pwd)/csmith" make -C build-files/ports/csmith install -j4
```

# Tests
Not avaliable

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~\qnx800\target\qnx\aarch64le\usr\local\bin\csmith $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~\qnx800\target\qnx\aarch64le\usr\local\lib\libcsmith.* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If `~/lib` or `~bin` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

