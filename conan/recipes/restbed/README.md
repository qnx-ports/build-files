# Pre-requisite

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

# Setup a Docker container - OPTIONAL
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

# Build and install restbed from source

Pre-requisite

* Build and install asio. [asio-docs]

```bash
# Build restbed lib
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <profile-name>: nto-7.1-aarch64-le,  nto-7.1-x86_64,     nto-8.0-aarch64-le,  nto-8.0-x86_64
# <version-number>: 4.8
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/restbed/all
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/restbed/all
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=4.8 $QNX_CONAN_ROOT/recipes/restbed/all --build=missing
```

# Build QNX tests for restbed

Pre-requisite

* Build and install asio. [asio-docs]
* Build and install Catch2. [Catch2-docs]

```bash
cd ~/qnx_workspace

# Clone restbed sources from QNX repository
git clone https://github.com/qnx-ports/restbed.git

# OR from Corvusoft official repository
git clone https://github.com/Corvusoft/restbed.git

cd restbed

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain and build new restbed
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <profile-name>: nto-7.1-aarch64-le,  nto-7.1-x86_64,     nto-8.0-aarch64-le,  nto-8.0-x86_64
# <version-number>: 4.8
#
# Usage [linux]:
#   conan install --version=<version-number> $QNX_CONAN_ROOT/recipes/restbed/tests
# Usage [QNX and Linux]:
#   conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/restbed/tests
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=4.8 $QNX_CONAN_ROOT/recipes/restbed/tests

cmake --preset conan-release

# For systems with less than 48 GB of memory, limit parallel build jobs to 6.
cmake --build build_tests/Release --parallel 6
```

# Run tests on Linux
```bash
# Run the tests using CTest
ctest --output-on-failure --test-dir build_tests/Release
```

# Run tests on QNX target

Pre-requisite

* Create a QEMU image with Python installed, >2 GB data size, and >20K data inodes. [mkqnximage-docs]
* Build and install cmake [cmake-docs]

```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# Define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf restbed_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir restbed_tests"

# Copy gtest build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* qnxuser@$TARGET_HOST:/data/home/qnxuser/restbed_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/qnxuser/restbed_tests

# Fix absolute paths within CTestTestfile.cmake
python ./ctest.py

# Run the tests using CTest
ctest --test-dir build_tests/Release
```

# CTest for restbed version=4.8

```bash
100% tests passed, 0 tests failed out of 116

Total Test time (real) =  25.11 sec
```

[asio-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/asio/README.md
[Catch2-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/catch2/README.md
[cmake-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/cmake/README.md
[mkqnximage-docs]: https://www.qnx.com/developers/docs/7.1/com.qnx.doc.neutrino.utilities/topic/m/mkqnximage.html
