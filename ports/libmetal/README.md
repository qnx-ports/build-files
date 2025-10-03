# libmetal [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libmetal.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libmetal.yml)

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

# Clone libmetal
git clone https://github.com/qnx-ports/libmetal

# Build libmetal
make -C build-files/ports/libmetal install JLEVEL=4
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/libmetal

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh

# Build libmetal
make -C build-files/ports/libmetal install JLEVEL=4
```

# How to run tests

**NOTE**: Custom QNX Image on RPi4 is used to perform the tests and report results.
The usual QNXE RPi4 image can be used but expect device.c test to fail on it, since custom bootup device initialization is required for it.

**NOTE**: To create custom RPi4 image with bootup reserved named physical regions, install the RPi4 BSP (com.qnx.qnx800.bsp.hw.raspberrypi_bcm2711_rpi4) from QNX Software Centre and customize in `bcm2711_init_raminfo.c`.

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move the library to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libmetal* qnxuser@$TARGET_HOST:/tmp

# Move the test binary to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/test-metal-shared qnxuser@$TARGET_HOST:/tmp
```

Run the tests

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Setup and run
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tmp
./test-metal-shared
```

**NOTE**: To enable debug symbols for compilation, append `-g` to `CFLAGS` in common.mk file
