# libcamera [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libcamera.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libcamera.yml)

This port is used for auto-white balance and auto-exposure for QNX RPi4 RPi5 Camera Module 3.

**Note**: QNX ports are only supported from a **Linux host** operating system
Supports QNX7.1 and QNX8.0

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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

# Clone libyaml which is a dependency of libcamera
git clone https://github.com/qnx-ports/libyaml.git

# Clone libcamera
git clone https://github.com/qnx-ports/libcamera.git

# Build libyaml first
QNX_PROJECT_ROOT="$(pwd)/libyaml" make -C build-files/ports/libyaml/ install -j4

# Build libcamera
QNX_PROJECT_ROOT="$(pwd)/libcamera" make -C build-files/ports/libcamera/ install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/libyaml.git
git clone https://github.com/qnx-ports/libcamera.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build libyaml first
QNX_PROJECT_ROOT="$(pwd)/libyaml" make -C build-files/ports/libyaml/ install -j4

# Build libcamera
QNX_PROJECT_ROOT="$(pwd)/libcamera" make -C build-files/ports/libcamera/ install -j4
```

# Tests

`libyaml-so.2` is a dependency of RPi4 and RPi5 camera. At runtime, observe to see auto-white balance and auto-exposure are working correctly.
