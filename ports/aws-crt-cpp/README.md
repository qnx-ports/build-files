# aws-crt-cpp [![Build](https://github.com/qnx-ports/build-files/actions/workflows/aws-crt-cpp.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/aws-crt-cpp.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone aws-crt-cpp and dependency
git clone https://github.com/qnx-ports/aws-crt-cpp.git
cd aws-crt-cpp
git submodule update --init --recursive
cd -
git clone https://github.com/qnx-ports/epoll.git

# Build epoll
make -C build-files/ports/epoll install JLEVEL=4

# Build aws-crt-cpp
make -C build-files/ports/aws-crt-cpp install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/aws-crt-cpp.git
git clone https://github.com/qnx-ports/epoll.git

# Perform submodule updates
cd aws-crt-cpp
git submodule update --init --recursive
cd -

# Source environment
source ~/qnx800/qnxsdp-env.sh

# Build epoll
make -C build-files/ports/epoll install JLEVEL=4

# Build aws-crt-cpp
make -C build-files/ports/aws-crt-cpp install JLEVEL=4
```

# How to run tests

**Note**: Below steps are for running the tests on a RPi4 target.

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move the test binary to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/aws_crt_cpp_tests/* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin


# Move aws-crt-cpp and dependent libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libaws* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libs2n* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libepoll* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Move test script to the target
scp ~/qnx_workspace/build-files/ports/aws-crt-cpp/test.sh qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
```

# Run the tests

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

export PATH=$PATH:/data/home/qnxuser/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

sh test.sh
```

There are a total of 199 tests. Known test skips and failures include:

- All MQTT IoT related tests are untested for now (117 tests)
- Few HTTP (3 pass and 3 failed) tests are skipped from running in test script since halt test script run due to segmentation/memory faults
  1. Tests which pass and cause memory fault (are supposed to):
  - HttpDownloadNoBackPressureHTTP1_1
  - HttpDownloadNoBackPressureHTTP2
  - HttpStreamUnActivated
  2. Tests which fail and cause Segmentation fault
  - HttpClientConnectionManagerResourceSafety
  - HttpClientConnectionWithPendingAcquisitions
  - HttpClientConnectionWithPendingAcquisitionsAndClosedConnections
