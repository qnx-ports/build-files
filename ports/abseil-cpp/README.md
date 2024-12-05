# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Before building abseil-cpp and its tests, you might want to first build and install `muslflt`
under the same staging directory. Projects using abseil-cpp on QNX might also want to link to
`muslflt` for consistent math behavior as other platforms. Without `muslflt`, some tests
may fail and you may run into inconsistencies in results compared to other platforms.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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
# Prerequisite: Install googletest
# Create staging directory, e.g. /tmp/staging
mkdir -p <staging-install-folder>
# Clone googletest
git clone https://github.com/qnx-ports/googletest.git
# Build googletest
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Prerequisite: Install muslflt
# Clone muslflt
git clone https://github.com/qnx-ports/muslflt.git
# Build muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4

# Clone abseil-cpp
git clone https://github.com/qnx-ports/abseil-cpp.git

# Build abseil-cpp
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/abseil-cpp.git
git clone https://github.com/qnx-ports/googletest.git
git clone https://github.com/qnx-ports/muslflt.git

# Create staging directory, e.g. /tmp/staging
mkdir -p <staging-install-folder>

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Prerequisite: Install googletest
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Prerequisite: Install muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4

# Build
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=4 install

# If building for QNX 7.1, set the QNX_SEVEN_COMPAT environment variable
QNX_SEVEN_COMPAT="true" QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/ports/abseil-cpp INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true JLEVEL=4 install
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
