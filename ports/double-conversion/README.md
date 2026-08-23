# double-conversion

**NOTE**: QNX ports are only supported from a Linux host operating system.

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

# Clone FLAC from upstream
cd ~/qnx_workspace
git clone https://github.com/google/double-conversion.git

# Build FLAC
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/double-conversion" make -C build-files/ports/double-conversion install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/google/double-conversion.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/double-conversion" make -C build-files/ports/double-conversion install -j4
```

# How to run tests

Make sure the directories exist on the target:
```bash
mkdir -p /data/home/qnxuser/double-conversion/lib
```

scp libraries and tests to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).

```bash
TARGET_HOST=

scp $QNX_TARGET/aarch64le/usr/local/bin/cctest qnxuser@$TARGET_HOST:/data/home/qnxuser/double-conversion/
scp $QNX_TARGET/aarch64le/usr/local/lib/libdouble-conversion* qnxuser@$TARGET_HOST:/data/home/qnxuser/double-conversion/lib/
```
