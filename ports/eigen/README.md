# Eigen [![Build](https://github.com/qnx-ports/build-files/actions/workflows/eigen.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/eigen.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Building Eigen
---
These Makefiles also install ported Eigen headers, but they are not required and you could
simply include / vendor this entire repository for those headers.

Before building Eigen and its tests, you might want to first build and install `muslflt`
under the same staging directory. Projects using Eigen on QNX might also want to link to
`muslflt` for consistent math behavior as other platforms. Without `muslflt`, some tests
may fail and you may run into inconsistencies in results compared to other platforms.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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

cd ~/qnx_workspace
# Create staging directory, e.g. /tmp/staging
mkdir -p <staging-install-folder>
# Prerequisite: Install muslflt
# Clone muslflt
git clone https://github.com/qnx-ports/muslflt.git
# Build muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true make -C build-files/ports/muslflt/ install -j4

# Clone eigen
git clone https://github.com/qnx-ports/eigen.git

# Build eigen
# Set BUILD_TESTING to ON to test eigen
BUILD_TESTING=OFF QNX_PROJECT_ROOT="$(pwd)/eigen" make -C build-files/ports/eigen INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/muslflt.git
git clone https://github.com/qnx-ports/eigen.git

# Create staging directory, e.g. /tmp/staging
mkdir -p <staging-install-folder>

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
# Prerequisite: Install muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true make -C build-files/ports/muslflt/ install -j4
# Build
QNX_PROJECT_ROOT="$(pwd)/eigen" make -C build-files/ports/eigen INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=4 install
```

# How to run tests

After Eigen is built and installed, all test binaries will be located under `<prefix>/bin/eigen_tests`
(prefix defaults to `/usr/local`).

Move files to the target (note, mDNS is configured from /boot/qnx_config.txt and
uses qnxpi.local by default):
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Copy tests to target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/eigen_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
# If you built with a staging directory, use that location instead:
#scp -r <staging-install-folder>/aarch64le/usr/local/bin/eigen_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# ssh onto the target
ssh qnxuser@$TARGET_HOST

# Run the tests
cd /data/home/qnxuser/bin/eigen_tests
for test in $(ls); do
    ./$test;
done
```

Run tests on the target

Note that the following test(s) are known to fail:

NonLinearOptimization

This is located under `unsupported/` and is known to behave unreliably even on Linux.

In addition, other tests may randomly fail due to quirks of QNX's default random number generator.
A known good seed to set is `EIGEN_SEED=1711113814`.
