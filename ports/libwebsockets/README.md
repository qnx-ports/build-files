# libwebsockets [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libwebsockets.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libwebsockets.yml)

**NOTE**: QNX ports are only supported from Linux host operating system

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

# Install dependencies
# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j$(nproc)

# Build libwebsockets
git clone https://github.com/qnx-ports/libwebsockets.git
make -C build-files/ports/libwebsockets install -j$(nproc)
```

# Compile the port for QNX on Ubuntu Host

```bash
# Source qnxsdp-env.sh in
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Install dependencies
# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j$(nproc)

# Build libwebsockets
git clone https://github.com/qnx-ports/libwebsockets.git
make -C build-files/ports/libwebsockets install -j$(nproc)
```

# How to Run Tests and Applications

**NOTE**: Tests are performed on [RPi4 target image available via QNX-E](https://www.qnx.com/developers/docs/qnxeverywhere/com.qnx.doc.target_images/topic/qsti/intro.html)

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib qnxuser@$TARGET_HOST:~/lib

# Move test binaries to the target
scp -r build-files/ports/libwebsockets/nto-aarch64-le/build/bin qnxuser@$TARGET_HOST:~/

# Move share binaries to the target for web based test
scp -r build-files/ports/libwebsockets/nto-aarch64-le/build/share qnxuser@$TARGET_HOST:~/
```

## Run the Test Server
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib
cd build
./libwebsockets-test-server
```
## Run the Test Client
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib
cd build
./libwebsockets-test-client 0.0.0.0
```

## Web Access Note
After starting the server, the test page should be accessible at:
 
http://$TARGET_HOST:7681/

## Note

For the current version, the web-based test code requires the server to fetch data from the `share` directory. The resource path is hardcoded during the build process.

To ensure the web-based tests work correctly, either:

- Replicate the host directory structure for the `share` directory on the target system, or
- Modify `CMAKE_INSTALL_PREFIX` in `common.mk` to match the target directory structure used for testing.
