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
mkdir -p ~/zenoh-c_workspace && cd ~/zenoh-c_workspace
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

# Install release zenoh-c libs into conan cache
```bash
# Install from binary package
# IMPORTANT: Linux only
# <version-number>: 1.4.0, 1.2.1
#
conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/binary
```

# Build and install zenoh-c from source

Pre-requisite

* build and install rust-toolchain [rust-toolchain-docs]

```bash
# Build zenoh-c lib
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 1.4.0
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/all
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/all
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=1.4.0 $QNX_CONAN_ROOT/recipes/zenoh-c/all
```

# Build QNX tests for zenoh-c

Pre-requisite

* build and install rust-toolchain [rust-toolchain-docs]

```bash
cd ~/qnx_workspace

# Clone zenoh-c sources from QNX repository
git clone https://github.com/qnx-ports/zenoh-c.git

# OR from eclipse-zenoh official repository
git clone https://github.com/eclipse-zenoh/zenoh-c.git

cd zenoh-c

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain
#
# <profile-name>: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
# <version-number>: 1.4.0
#
# Usage [linux]:
#   conan install --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/tests
# Usage [QNX and Linux]:
#   conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/tests
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=1.4.0 $QNX_CONAN_ROOT/recipes/zenoh-c/tests

# Build new zenoh-c
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
# <version-number>: 1.4.0
#
# Usage [linux]:
#   conan build --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/tests
# Usage [QNX]:
#   conan build -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/zenoh-c/tests
conan build -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=1.4.0 $QNX_CONAN_ROOT/recipes/zenoh-c/tests
```

# Run tests on QNX target

Pre-requisite

* build and install cmake [cmake-docs]

```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# Define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf zenoh-c_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir zenoh-c_tests"

# Copy gtest build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* qnxuser@$TARGET_HOST:/data/home/qnxuser/zenoh-c_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/qnxuser/zenoh-c_tests

# Fix absolute paths within CTestTestfile.cmake
python ./ctest.py

cd ./build_tests/Release/

ctest
```
CTest for zenoh-c version 1.4.0 reports a lot of error

```bash
42% tests passed, 11 tests failed out of 19

Total Test time (real) =   8.11 sec
```

[rust-toolchain-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/rust-toolchain/README.md
[cmake-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/cmake/README.md
