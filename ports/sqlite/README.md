# sqlite [![Build](https://github.com/qnx-ports/build-files/actions/workflows/sqlite.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/sqlite.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone -b version-3.50.0 https://github.com/sqlite/sqlite.git

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build sqlite
# set INSTALL_ROOT=/path/to/root to install SQLite to other directory
QNX_PROJECT_ROOT="$PWD/sqlite" JLEVEL=4 make -C build-files/ports/sqlite clean instal
```

# Deploy binaries via SSH
This port provides the all binaries obtained from QSC, but may be slightly more updated.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/sqlite3 $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libsqlite3* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

# Tests
Obly fuzzy tests are available and it has been provided insider `build-files/ports/sqlite/test.result`
