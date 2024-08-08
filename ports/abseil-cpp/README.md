# Compile the port for QNX

**Note**: QNX ports areo only supported from a **Linux host** operating system

## PRE-REQUISITE
**NOTE**: An installation of google test on your **SDP** is required. Please follow the build instruction for `googletest` with `gmock` and make sure it is installed to the same SDP folder that you will source below.

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

# Clone abseil-cpp
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/abseil-cpp.git

# Build abseil-cpp
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp JLEVEL=$(nproc) install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/abseil-cpp.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp JLEVEL=$(nproc) install
```

# How to run tests

**RPI4**: Move abseil-cpp library and the test binary to the target:

e.g.

    - scp ~/qnx_workspace/build-files/ports/abseil-cpp/nto-aarch64-le/build/bin/* qnxuser@<target-ip-address>:/data/home/qnxuser/bin
    - scp $(find ~/qnx_workspace/build-files/ports/abseil-cpp/nto-aarch64-le/build/ -name "libabsl*") qnxuser@<target-ip-address>:/data/home/qnxuser/lib

ssh into target and run the binaries you copied over to target `/data/home/qnxuser/bin` folder. 

In order to run all test binaries, you can copy over the qnxtests.sh file and run the file instead.

---
Tests results are provided on the wiki: https://wikis.rim.net/display/OSG/QNX+Open+Source+Group
