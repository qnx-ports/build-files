# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Before building abseil-cpp and its tests, you might want to first build and install `muslflt`
under the same staging directory. Projects using abseil-cpp on QNX might also want to link to
`muslflt` for consistent math behavior as other platforms. Without `muslflt`, some tests
may fail and you may run into inconsistencies in results compared to other platforms.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=$(nproc) install
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
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=$(nproc) install
```

# How to run tests

**RPI4**: Move abseil-cpp library and the test binary to the target (note, mDNS
is configured from /boot/qnx_config.txt and uses qnxpi.local by default):

e.g.
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp ~/qnx_workspace/build-files/ports/abseil-cpp/nto-aarch64-le/build/bin/* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp $(find ~/qnx_workspace/build-files/ports/abseil-cpp/nto-aarch64-le/build/ -name "libabsl*") qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libgmock* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libgtest* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

ssh into target and run the binaries you copied over to target `/data/home/qnxuser/bin` folder. 

In order to run all test binaries, you can copy over the qnxtests.sh file and run the file instead.

---
