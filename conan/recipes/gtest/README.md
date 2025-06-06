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

# Build and install release gtest for QNX into conan cache
```bash
cd ~/qnx_workspace

# Build gtest for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 1.10.0, 1.13.0, 1.14.0
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/gtest/all
```

# Build QNX tests for gtest

Pre-requisite

* build and install cmake to the target
  - $QNX_CONAN_ROOT/recipes/cmake/README.md>

```bash
cd ~/qnx_workspace

# Clone gtest sources from QNX repository
git clone https://github.com/qnx-ports/googletest.git

# OR from google official repository
git clone https://github.com/google/googletest.git

cd googletest

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 1.10.0, 1.13.0, 1.14.0
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/gtest/tests

cmake --preset conan-release

cmake --build build_tests/Release -- -j
```

# Run tests on QNX target

**NOTE**: For some tests gtest needs root rights. Please use root.

```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# Define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# Remove old test dir on target
ssh root@$TARGET_HOST "rm -rf gtest_tests"

# Create new test dir on target
ssh root@$TARGET_HOST "mkdir gtest_tests"

# Copy gtest build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* root@$TARGET_HOST:/data/home/root/gtest_tests/

# Ssh into the target (some unittests need root)
ssh root@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/root/gtest_tests

# Fix absolute paths within CTestTestfile.cmake
python ./ctest.py

cd ./build_tests/Release/

ctest
```
