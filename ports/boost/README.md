# Boost [![Build](https://github.com/qnx-ports/build-files/actions/workflows/boost.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/boost.yml)

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

# Clone boost
cd ~/qnx_workspace
git clone https://github.com/boostorg/boost.git && cd boost
git checkout boost-1.82.0
git submodule update --init --recursive

# Apply a tools patch
cd tools/build && git apply ../../../build-files/ports/boost/tools_qnx.patch
cd ~/qnx_workspace

# Build boost
make -C build-files/ports/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j4

# Build and install tests
./build-files/ports/boost/build_and_install_tests.sh
```

# Compile the port for QNX
```bash
# Clone the build-files and boost repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/boostorg/boost.git

cd boost
git checkout boost-1.82.0
git submodule update --init --recursive
cd tools/build && git apply ../../../build-files/ports/boost/tools_qnx.patch && cd -
cd ../

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
make -C build-files/ports/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j4

# Build and install tests
./build-files/ports/boost/build_and_install_tests.sh
```

Currently, when numpy is installed on your host system, the build fails:

```console
/usr/local/lib/python3.8/dist-packages/numpy/core/include/numpy/npy_endian.h:13:14: fatal error: endian.h: No such file or directory
   13 |     #include <endian.h>
```

The workaround is to run `sudo pip3 uninstall numpy` or `pip3 uninstall numpy` to uninstall numpy

# Test instruction

`build_and_install_tests.sh` installs tests at $QNX_TARGET/aarch64le/usr/local/bin/boost_tests.
(note, mDNS is configured from /boot/qnx_config.txt and uses qnxpi.local by default)
```bash
# Make sure /data/home/qnxuser/bin and /data/home/qnxuser/lib exist on your target

TARGET_HOST=<target-ip-address-or-hostname>

# Move boost tests
scp -r $QNX_TARGET/aarch64le/usr/local/bin/boost_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
# Move boost library
scp $QNX_TARGET/aarch64le/usr/local/lib/libboost* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# ssh into the target
ssh qnxuser@$TARGET_HOST

# Add boost library to LD_LIBRARAY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

cd /data/home/qnxuser/bin/boost_tests

# You will see boost tests under each boost library folder
.
├── atomic
│   ├── atomic_api
│   ├── atomicity
│   ├── ...
├── chrono
│   ├── arithmetic_pass_h
│   ├── chrono_unit_test_d
│   ├── ...

# cd into each directory and run the tests
cd atomic
./atomic_api
./atomicity
cd ../chrono
./arithmetic_pass_h
./chrono_unit_test_d

# A test folder might contain a .so file which will be needed to run the tests.
# For example, system folder has libthrow_test.so.1.82.0. Move it to /data/home/qnxuser/lib
cp ./system/libthrow_test.so.1.82.0 /data/home/qnxuser/lib
```
