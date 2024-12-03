**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Clone sqlite_orm
cd ~/qnx_workspace
git clone https://github.com/fnc12/sqlite_orm.git && cd sqlite_orm

# Checkout version 1.9
git checkout v1.9

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Build sqlite_orm
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/sqlite_orm" make -C build-files/ports/sqlite_orm JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Clone sqlite_orm
cd ~/qnx_workspace
git clone https://github.com/fnc12/sqlite_orm.git && cd sqlite_orm

# Checkout version 1.9
git checkout v1.9

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Build sqlite_orm
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/sqlite_orm" make -C build-files/ports/sqlite_orm JLEVEL=4 install
```

# How to run tests
```bash
cd ~/qnx_workspace

# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer the unit_test to target
scp build-files/ports/sqlite_orm/nto-aarch64/le/build/tests/unit_tests qnxuser@$TARGET_HOST:/data/home/qnxuser
```
```bash
# ssh to the target
ssh qnxuser@$TARGET_HOST

# Run test script
cd /home/data/qnxuser
./unit_tests
```
### Known issues with sqlite_orm testing
```bash

```
