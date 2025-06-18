# Fast-DDS [![Build](https://github.com/qnx-ports/build-files/actions/workflows/Fast-DDS.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/Fast-DDS.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system
Supports QNX7.1 and QNX8.0

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

# Dependency warning

You should compile and install its dependencies before proceeding (in order). If you specify `INSTALL_ROOT` or `INSTALL_ROOT_nto` for any of the dependencies below, make sure you set the same `INSTALL_ROOT` across the board.
+ [`asio`](https://github.com/qnx-ports/build-files/tree/main/ports/asio)
+ [`tinyxml2`](https://github.com/qnx-ports/build-files/tree/main/ports/tinyxml2)
+ [`Fast-CDR`](https://github.com/qnx-ports/build-files/tree/main/ports/Fast-CDR)
+ [`foonathan_memory_vendor`](https://github.com/qnx-ports/build-files/tree/main/ports/foonathan_memory_vendor)

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

# Clone Fast-DDS
git clone -b qnx_v2.14.4 https://github.com/qnx-ports/Fast-DDS.git

# Build Fast-DDS, set INSTALL_ROOT to choose the installation destination
QNX_PROJECT_ROOT="$(pwd)/Fast-DDS" make -C build-files/ports/Fast-DDS/ INSTALL_ROOT=<staging-install-folder> install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b qnx_v2.14.4 https://github.com/qnx-ports/Fast-DDS.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build Fast-DDS, set INSTALL_ROOT to choose the installation destination
QNX_PROJECT_ROOT="$(pwd)/Fast-DDS" make -C build-files/ports/Fast-DDS/ INSTALL_ROOT=<staging-install-folder> install -j4
```

# Tests
See test results in `fdds.test.result`; NOT all tests are passed.

### Test summary
97% tests passed, 445 tests failed out of 17191