**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# Build the Docker image and create a container
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone boost
cd ~/qnx_workspace
git clone https://github.com/boostorg/boost.git && cd boost
git checkout boost-1.82.0
git submodule update --init --recursive

# Apply a tools patch
cd tools/build && git apply ../../../build-files/boost/tools_qnx.patch
cd ~/qnx_workspace

# Build boost
make -C build-files/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j$(nproc)

# Build and install tests
./build-files/boost/build_and_install_tests.sh
```

# Compile the port for QNX
```bash
# Clone the build-files and boost repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://github.com/boostorg/boost.git

cd boost
git checkout boost-1.82.0
git submodule update --init --recursive
cd tools/build && git apply ../../../build-files/boost/tools_qnx.patch && cd -
cd ../

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
make -C build-files/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j$(nproc)

# Build and install tests
./build-files/boost/build_and_install_tests.sh
```

Currently, when numpy is installed on your host system, the build fails:

```console
/usr/local/lib/python3.8/dist-packages/numpy/core/include/numpy/npy_endian.h:13:14: fatal error: endian.h: No such file or directory
   13 |     #include <endian.h>
```

The workaround is to run `sudo pip3 uninstall numpy` or `pip3 uninstall numpy` to uninstall numpy
