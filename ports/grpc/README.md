# Compile the port for QNX

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
cd ~/qnx_workspace

# Install pre-requisites. Can be skipped if you have done them before.
# You can also follow the instructions in https://github.com/qnx-ports/build-files/tree/main/ports

# Install muslflt
git clone https://github.com/qnx-ports/muslflt.git
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ install JLEVEL=4

# Install googletest
git clone https://github.com/qnx-ports/googletest.git
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Clone grpc
git clone https://github.com/qnx-ports/grpc.git && cd grpc
git submodule update --init

# Setup submodules
cd third_party/googletest
git remote add qnx https://github.com/qnx-ports/googletest.git
git fetch --all
git switch qnx_v1.13.0 
git pull
cd ~/qnx_workspace/grpc/third_party/protobuf
git remote add qnx https://github.com/qnx-ports/protobuf.git
git fetch --all
git switch qnx-v27.2
git pull
git submodule update --init
cd ~/qnx_workspace

# Build grpc (with hello-world example)
make -C build-files/ports/grpc/ install JLEVEL=4
```

# Compile the port for QNX
```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Install pre-requisites. Can be skipped if you have done them before.
# You can also follow the instructions in https://github.com/qnx-ports/build-files/tree/main/ports

# Install muslflt
git clone https://github.com/qnx-ports/muslflt.git
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ install JLEVEL=4

# Install googletest
git clone https://github.com/qnx-ports/googletest.git
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Clone grpc
git clone https://github.com/qnx-ports/grpc.git && cd grpc
git submodule update --init

# Setup submodules
cd third_party/googletest
git remote add qnx https://github.com/qnx-ports/googletest.git
git fetch --all
git switch qnx_v1.13.0 
git pull
cd ~/qnx_workspace/grpc/third_party/protobuf
git remote add qnx https://github.com/qnx-ports/protobuf.git
git fetch --all
git switch qnx-v27.2
git pull
git submodule update --init
cd ~/qnx_workspace

# Build grpc (with hello-world example)
make -C build-files/ports/grpc/ install JLEVEL=4
```

# How to run tests

Set up the test environment (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)
```bash
TARGET_HOST=<target-ip-address-or-hostname>
```
Now we copy protobuf test binaries and data to target. We need to first go to the correct directory.
If you used `INSTALL_ROOT_nto`, run 
```bash
cd $INSTALL_ROOT_nto/aarch64le
```

If you installed protobuf to SDP, run
```bash
cd $QNX_TARGET/aarch64le
```
**MAKE SURE YOU ARE AT THE CORRECT DIRECTORY**

```bash

scp ./usr/local/lib/libprotobuf.so* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libutf8_* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libprotoc.so* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libgtest.so* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libabsl_* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libgpr* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libre2* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libgrpc* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libupb* qnxuser@$TARGET_HOST:~/lib
scp ./usr/lib/libcares* qnxuser@$TARGET_HOST:~/lib
scp ./usr/local/lib/libaddress* qnxuser@$TARGET_HOST:~/lib

scp -r ./usr/local/bin/grpc_tests qnxuser@$TARGET_HOST:~/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
cd /data/home/qnxuser

ntpdate -sb 0.pool.ntp.org 1.pool.ntp.org 
mkdir -p /tmp
export TMPDIR=/tmp
python3 -m ensurepip --root /  
python3 -m pip install six
```

For `QNX710`, you need to edit `/etc/hosts` file to have the following content:

```
#
# Host Database
#
127.0.0.1       localhost.localdomain localhost
::1             localhost.localdomain localhost
```

```bash
cd ~/grpc_tests
python3 ./tools/run_tests/run_tests.py -l c++
```

# Known issues
