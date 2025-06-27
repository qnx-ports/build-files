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

# Build and install release up-cpp for QNX into conan cache

Pre-requisite

* build and install protobuf 3.21.12 for QNX and for Linux
  - $QNX_CONAN_ROOT/recipes/protobuf/README.md>
* build and install gtest 1.14.0 for QNX
  - $QNX_CONAN_ROOT/recipes/gtest/README.md>
* build and install up-core-api 1.6.0-alpha2 for QNX
  - $QNX_CONAN_ROOT/recipes/up-core-api/README.md>

```bash
cd ~/qnx_workspace

# Install protobuf for Linux
conan create --version=3.21.12 --build=missing $QNX_CONAN_ROOT/recipes/protobuf/all

# Install protobuf for QNX
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=3.21.12 --build=missing $QNX_CONAN_ROOT/recipes/protobuf/all

# Build gtest for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=1.14.0 $QNX_CONAN_ROOT/recipes/gtest/all

# Build up-core-api for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=1.6.0-alpha2 $QNX_CONAN_ROOT/recipes/up-core-api/release

# Build up-cpp for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 1.0.0-rc0, 1.0.0, 1.0.1-rc1, 1.0.1
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> --build=missing $QNX_CONAN_ROOT/recipes/up-cpp/release
```

# Build QNX tests for up-cpp

Pre-requisite

* build and install cmake to the target
  - $QNX_CONAN_ROOT/recipes/cmake/README.md>

```bash
cd ~/qnx_workspace

# Clone up-cpp sources from QNX repository
git clone https://github.com/qnx-ports/up-cpp.git 

# OR from uProtocol official repository
git clone https://github.com/eclipse-uprotocol/up-cpp.git

cd up-cpp

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 1.0.0-rc0, 1.0.0, 1.0.1-rc1, 1.0.1
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> --build=missing $QNX_CONAN_ROOT/recipes/up-cpp/tests

cmake --preset conan-release

cmake --build build_tests/Release -- -j
```

# Run tests on QNX target
```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# Define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf up-cpp_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir up-cpp_tests"

# Copy gtest build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* qnxuser@$TARGET_HOST:/data/home/qnxuser/up-cpp_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/qnxuser/up-cpp_tests

# Fix absolute paths within CTestTestfile.cmake
python ./ctest.py

cd ./build_tests/Release/

ctest
```

CTest reports no error

```bash
100% tests passed, 0 tests failed out of 269

Total Test time (real) =  11.09 sec
```
