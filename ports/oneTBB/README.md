# oneTBB [![Build](https://github.com/qnx-ports/build-files/actions/workflows/oneTBB.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/oneTBB.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

## PRE-REQUISITE
**NOTE**: An installation of google test on your **SDP** is required. Please follow the build instruction for `googletest` with `gmock` and make sure it is installed to the same SDP folder that you will source below.

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

# Clone oneTBB
git clone https://github.com/qnx-ports/oneTBB.git

# Build oneTBB
make -C build-files/ports/oneTBB JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/oneTBB.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
make -C build-files/ports/oneTBB JLEVEL=4 install
```

# How to run tests

Install test runtime dependencies to the target.
```bash
scp $QNX_TARGET/aarch64le/lib/libgomp.so* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r ~/qnx_workspace/build-files/ports/oneTBB/nto-aarch64-le/build/qcc_12.2_cxx14_64_release/* qnxuser@$TARGET_HOST:/data/home/qnxuser

scp -r ~/qnx_workspace/oneTBB qnxuser@$TARGET_HOST:/data/home/qnxuser
```

Execute the tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

export TBBROOT=/data/home/qnxuser/oneTBB
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$TBBROOT/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$TBBROOT/include
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/data/home/qnxuser/pkgconfig

# Run tests
cd /data/home/qnxuser
for test in $(ls | grep -E "^(test_|conformance_)") ; do
    ./$test 2>&1 | tee -a log.txt
done
```
