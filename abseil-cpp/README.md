# Compile the port for QNX

**Note**: QNX ports areo only supported from a **Linux host** operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Build the Docker image and create a container
git clone https://gitlab.com/qnx/ports/docker-build-environment.git && cd docker-build-environment
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone abseil-cpp
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/abseil-cpp.git

# Build abseil-cpp
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/abseil-cpp JLEVEL=$(nproc) install
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
QNX_PROJECT_ROOT="$(pwd)/abseil-cpp" make -C build-files/abseil-cpp JLEVEL=$(nproc) install
```

# How to run tests

**RPI4**: Move abseil-cpp library and the test binary to the target:

e.g.

    - scp ~/build-files/abseil-cpp/nto-aarch64-le/build/bin/* root<target-ip-address>:/usr/bin
    - scp ~/build-files/abseil-cpp/nto-aarch64-le/build/lib* root@<target-ip-address>:/usr/lib

Make sure to find all libsabsl* libraries and copy them over to the target: installed under ~/qnx800_ea/target/qnx/aarch64le/usr/lib

ssh into target and run the binary.

In order to run all test binaries, you can copy over the qnxtests.sh file and run the file instead.

**QEMU**: Move abseil library and test binary to qemu instance:

    - scp ~/build-files/abseil-cpp/nto-x86_64/build/bin/* root<target-ip-address>:/system/xbin
    - scp ~/build-files/abseil-cpp/nto-x86_64/build/lib/lib* root<target-ip-address>:/system/lib

---
Tests results are provided on the wiki: https://wikis.rim.net/display/OSG/QNX+Open+Source+Group