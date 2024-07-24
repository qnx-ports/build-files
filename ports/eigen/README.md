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

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone eigen
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/eigen.git

# Build eigen
QNX_PROJECT_ROOT="$(pwd)/eigen" make -C build-files/ports/eigen INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=$(nproc) install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/eigen.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
QNX_PROJECT_ROOT="$(pwd)/eigen" make -C build-files/ports/eigen INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=$(nproc) install
```

# How to run tests

After Eigen is built and installed, all test binaries will be located under `<prefix>/bin/eigen_tests`
(prefix defaults to `/usr/local`). Note that the following test(s) are known to fail:

NonLinearOptimization

This is located under `unsupported/` and is known to behave unreliably even on Linux.

In addition, other tests may randomly fail due to quirks of QNX's default random number generator.
A known good seed to set is `EIGEN_SEED=1711113814`.
