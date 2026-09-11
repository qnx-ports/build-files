# ARM ComputeLibrary [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ComputeLibrary.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ComputeLibrary.yml)

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

# Clone ComputeLibrary
cd ~/qnx_workspace
git clone -b qnx-v53.0.0 https://github.com/qnx-ports/ComputeLibrary.git

# Build ComputeLibrary
BUILD_TESTING="ON" make -C build-files/ports/ComputeLibrary install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b qnx-v53.0.0 https://github.com/qnx-ports/ComputeLibrary.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build ComputeLibrary
BUILD_TESTING="ON" make -C build-files/ports/ComputeLibrary install JLEVEL=4
```

# How to run tests

scp libraries and tests to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move neon test binaries to your QNX target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/ComputeLibrary_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Move the ARM Compute Library to your QNX target
scp $QNX_TARGET/aarch64le/usr/local/lib/libarm_compute* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
# Move the ARM Compute Library to your QNX target
scp $QNX_TARGET/aarch64le/lib/libgomp.so.1 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

**Note**: Do not build with `ARM_COMPUTE_ENABLE_OPENMP=ON` since runtime failures are observed. More information in below section.

Run tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run benchmark and validation tests
cd /data/home/qnxuser/bin/ComputeLibrary_tests
./arm_compute_benchmark
./arm_compute_validation

# Examples are optional to run (and can be build by passing BUILD_EXAMPLES=ON to build command)
```

**Note**: Tests fail with runtime error when ComputeLibrary is build with option `ARM_COMPUTE_ENABLE_OPENMP` as `ON`. Reason being the aarch64 OpenMP runtime assembly stub (kmp_invoke_microtask) crashes because it has a hardcoded limit of passing a maximum of 15 captured variables to a parallel thread block, and ComputeLibrary tries to pass 22.
