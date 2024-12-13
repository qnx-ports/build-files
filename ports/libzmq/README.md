**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Clone libzmq
git clone https://github.com/zeromq/libzmq.git && cd libzmq

# Checkout version 4.3.5
git checkout v4.3.5

# Build the Docker image and create a container
cd ~/qnx_workspace/build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Build sqlite_orm
cd ~/qnx_workspace
make -C libzmq/build_qnx JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Clone libzmq
git clone https://github.com/zeromq/libzmq.git && cd libzmq

# Checkout version 4.3.5
git checkout v4.3.5

# Now you are in the Docker container

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Build sqlite_orm
cd ~/qnx_workspace
make -C libzmq/build_qnx JLEVEL=4 install
```

# How to run tests
```bash
cd ~/qnx_workspace

# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer libzmq library to target
scp $QNX_TARGET/aarch64le/usr/lib/libzmq.so.5 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer the unit_test to target
scp $QNX_TARGET/aarch64le/usr/bin/test_* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Transfer test script to target
scp build-files/ports/libzmq/script/run_tests.sh qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
```
```bash
# ssh to the target
ssh qnxuser@$TARGET_HOST

# Increase maximum allowed file handles
# type "root" when prompted for password
su
ulimit -n 1200

# Export library path and TMPDIR
export LD_LIBRARY_PATH=/data/home/qnxuser/lib:$LD_LIBRARY_PATH
mkdir -p /data/home/qnxuser/tmp
export TMPDIR=/data/home/qnxuser/tmp

# Run test script
cd /data/home/qnxuser/bin
sh run_tests.sh

# Exit root
exit
```
### Failed tests
```bash
# Fails because relative paths causes bind to fail. 
# A fix is being worked on righ now
# Workaround for now is to convert all relative paths to absolute paths before calling bind().
./test_use_fd
./test_rebind_ipd
./test_reconnect_ivl
```