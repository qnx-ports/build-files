# nghttp2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/nghttp2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/nghttp2.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Please make sure you have `com.qnx.qnx800.osr.libev` QNX Package installed to your SDP

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Clone brotli, jansson and nghttp2
git clone -b v1.1 https://github.com/google/brotli.git
git clone https://github.com/qnx-ports/jansson.git
git clone https://github.com/qnx-ports/nghttp2.git

# Build brotli
QNX_PROJECT_ROOT="$(pwd)/brotli" make -C build-files/ports/brotli/ install -j4

# Build jansson
make -C build-files/ports/jansson/ install -j4

# Clone nghttp2 submodules
cd nghttp2
git submodule update --init --recursive
cd -

# Build nghttp2
make -C build-files/ports/nghttp2/ install -j4
# To build nghttp2 with tests, use the command
BUILD_STATIC_LIBS=ON BUILD_TESTING=ON make -C build-files/ports/nghttp2/ install -j4
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b v1.1 https://github.com/google/brotli.git
git clone https://github.com/qnx-ports/jansson.git
git clone https://github.com/qnx-ports/nghttp2.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh

# Build brotli
QNX_PROJECT_ROOT="$(pwd)/brotli" make -C build-files/ports/brotli/ install -j4

# Build jansson
make -C build-files/ports/jansson/ install -j4

# Clone nghttp2 submodules
cd nghttp2
git submodule update --init --recursive
cd -

# Build nghttp2
make -C build-files/ports/nghttp2/ install -j4
# To build nghttp2 with tests, use the command
BUILD_STATIC_LIBS=ON BUILD_TESTING=ON make -C build-files/ports/nghttp2/ install -j4
```

# How to Run Tests and Applications

**NOTE**: QNX on RPi4 is used to perform the tests and report results.

1. To run tests

```bash
export TARGET_IP=<target-ip-address-or-hostname>

# Move the test binaries to the target
scp ~/qnx_workspace/build-files/ports/nghttp2/nto-aarch64-le/build/tests/* qnxuser@$TARGET_IP:~/bin

# To run the tests
ssh qnxuser@$TARGET_IP

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib
export PATH=$PATH:/data/home/qnxuser/bin

./main
./failmalloc
```

2. To run applications

- Applications have following library dependencies:
  - libm.so.3
  - libsocket.so.4
  - libnghttp2.so.14
  - libxml2.so.2
  - libev.so.4
  - libssl.so.3
  - libcrypto.so.3
  - libcares.so.8
  - libjansson.so.4
  - libz.so.2
  - libbrotlienc.so.1
  - libbrotlidec.so.1
  - libc++.so.2
  - libc.so.6
  - libgcc_s.so.1
  - liblzma.so.5
  - libiconv.so.1
  - libbrotlicommon.so.1

```bash
# Transfer the necessary libraries from host SDP to target
export INSTALL_DIR=<library-installation-directory>

scp $INSTALL_DIR/libjansson* $INSTALL_DIR/libbrotli* $INSTALL_DIR/libnghttp2* qnxuser@$TARGET_IP:~/lib

# If any of the above libraries are missing on your QNX target, transfer them from your host SDP to target's lib directory. For example,
scp $QNX_TARGET/aarch64le/usr/lib/libev.so* qnxuser@$TARGET_IP:~/lib

# Transfer the application binaries from host
scp inflatehd deflatehd nghttp* h2load qnxuser@$TARGET_IP:~/bin

# Run the application on target. Example for nghttp
./nghttp https://nghttp2.org
```
