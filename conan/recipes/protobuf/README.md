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

# Build and install release protobuf for QNX into conan cache
```bash
cd ~/qnx_workspace

# Build protobuf for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 3.15.0, 3.21.12, 5.27.2
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> --build=missing $QNX_CONAN_ROOT/recipes/protobuf/all
```

# Build QNX tests for protobuf
```bash
cd ~/qnx_workspace

# Build protobuf for Linux host
#
# <version-number>: 3.15.0, 3.21.12
# IMPORTANT: tests of 5.27.2 are crashed due to internal hardcoded paths
#
conan create --version=<version-number> --build=missing $QNX_CONAN_ROOT/recipes/protobuf/all

# Clone protobuf sources from QNX repository
git clone https://github.com/qnx-ports/protobuf.git 

# OR from official repository
git clone https://github.com/protocolbuffers/protobuf.git

cd protobuf

# Update submodules that are needed for unit testing.
git submodule update --init --recursive

cd cmake

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain for QNX target
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 3.15.0, 3.21.12
# IMPORTANT: tests of 5.27.2 are crashed due to internal hardcoded paths
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/protobuf/tests

cmake --preset conan-release

cmake --build build_tests/Release -- -j
```

# Run tests on QNX target
```bash
# Define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf protobuf_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir protobuf_tests"

# Copy protobuf build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/../* qnxuser@$TARGET_HOST:/data/home/qnxuser/protobuf_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

cd /data/home/qnxuser/protobuf_tests/cmake/build_tests/Release/

./tests
```

You may have failed tests.

v3.15.0: 
    - Tests use absolute paths to the sources, so testing on different machines may cause FAILED tests.
Common :
    - Some tests are FAILED due to qnx number-to-string formatting.
    - You may see "std::bad_alloc" this caused by insufficient RAM please configure QNX target with at least 5Gb
