**NOTE**: QNX ports are only supported from a Linux host operating system


# Pre-requisite

* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)
  - https://www.qnx.com/products/everywhere/ (**Non-Commercial Use**)
* Install Docker on Ubuntu - OPTIONAL
  - https://docs.docker.com/engine/install/ubuntu/
* Install venv - recomended by conan documentation - OPTIONAL
  - https://docs.python.org/3/library/venv.html
* Install Conan2
  - https://docs.conan.io/2/installation.html

# Create a workspace

```bash
# Clone conan recipes
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
```

# Setup a Docker container
```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# Source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Update conan setting for QNX8.0
```bash
# Setup conan root folder
export QNX_CONAN_ROOT=$(realpath ~/qnx_workspace/build-files/conan)

# Update conan settings for QNX8.0 support
conan config install $QNX_CONAN_ROOT/tools/qnx-8.0-extension/settings_user.yml
```

# Build and install release cmake for QNX into conan cache
```bash
cd ~/qnx_workspace

# Build cmake for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 3.31.6, 3.31.7
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/cmake/3.x.x
```

# Setup QNX qemu target
```bash
#build and run qemu QNX image for testing
mkqnximage --type=qemu --arch=x86_64 --clean --run --force  --python=yes --ram=6G --data-size=8196 --data-inodes=400000
```

# Deploy cmake on QNX target
```bash
cd ~/qnx_workspace

mkdir stage_cmake

export QNX_CMAKE_STAGE=$(realpath ~/qnx_workspace/stage_cmake)

# Copy cmake to stage folder
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 3.31.6, 3.31.7
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 \
    --requires=cmake/3.31.7 \
    -d=direct_deploy \
    --deployer-folder=$QNX_CMAKE_STAGE

# Define target IP address
export TARGET_HOST=<target-ip-address-or-hostname>

# Copy cmake to your QNX target
scp -r $QNX_CMAKE_STAGE/direct_deploy/cmake qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

# Build QNX tests for cmake

```bash
cd ~/qnx_workspace

# Clone supported version of cmake
git clone --branch=v3.31.7 https://github.com/Kitware/CMake.git

cd CMake

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 3.31.7
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=3.31.7 $QNX_CONAN_ROOT/recipes/cmake/tests

cmake --preset conan-release

cmake --build build_tests/Release -- -j
```

# Run tests on QNX target
```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf cmake_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir cmake_tests"

# Copy cmake build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* qnxuser@$TARGET_HOST:/data/home/qnxuser/cmake_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/qnxuser/cmake_tests

# Fix absolute paths
python ./ctest.py

cd ./build_tests/Release/

ctest
```
CTest for cmake version=3.31.7

Most of the failed tests were caused by a missing compiler on the target system and a wide range of missing system tools.

```bash
29% tests passed, 484 tests failed out of 678

Label Time Summary:
CUDA       =  22.26 sec*proc (14 tests)
Fortran    =  47.43 sec*proc (18 tests)
HIP        =  11.87 sec*proc (9 tests)
ISPC       =   9.38 sec*proc (7 tests)

Total Test time (real) = 2644.78 sec
```
