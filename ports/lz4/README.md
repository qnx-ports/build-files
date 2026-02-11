# lz4 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lz4.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lz4.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Clone lz4
git clone https://github.com/lz4/lz4.git

# Build lz4
make -C build-files/ports/lz4 install JLEVEL=4
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/lz4/lz4.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh

# Build lz4
make -C build-files/ports/lz4 install JLEVEL=4
```

# How to run tests

Move the lz4 CLI tools to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Set up directories
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER/lz4"

# Move the test binary to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/lz4 qnxuser@$TARGET_HOST:~/lz4
scp -r $QNX_TARGET/aarch64le/usr/local/bin/lz4cat qnxuser@$TARGET_HOST:~/lz4
scp -r $QNX_TARGET/aarch64le/usr/local/bin/unlz4 qnxuser@$TARGET_HOST:~/lz4
```

Run the tests

```bash
# Navigate to where binaries were installed
cd ~/lz4

# Setup and run
# Create a file you want to compress
./lz4 filename filename.lz4
./lz4cat filename.lz4
./unlz4 filename.lz4 outputfilename
```
