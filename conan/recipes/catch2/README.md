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

# Detect build profile
conan profile detect

# Update conan settings for QNX8.0 support
conan config install $QNX_CONAN_ROOT/tools/qnx-8.0-extension/settings_user.yml
```

# Build and install release catch2 for QNX into conan cache
```bash
cd ~/qnx_workspace

#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <profile-name>: nto-7.1-aarch64-le,  nto-7.1-x86_64,     nto-8.0-aarch64-le,  nto-8.0-x86_64
# <version-number>: 3.6.0, 2.13.10
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/catch2/<3.x.x|2.x.x>
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/catch2/<3.x.x|2.x.x>
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=3.6.0 $QNX_CONAN_ROOT/recipes/catch2/3.x.x
```

# Deploy catch2
```bash
cd ~/qnx_workspace

mkdir stage_catch2

PATH_2_STAGE=$(realpath ~/qnx_workspace/stage_catch2)

# deploy catch2 to the stage folder
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 \
    --requires=catch2/3.6.0 \
    --deployer=direct_deploy \
    --deployer-folder=$PATH_2_STAGE

# copy catch2 into SDP
cp -r $PATH_2_STAGE/direct_deploy/catch2/include $QNX_TARGET/x86_64/usr/local/
cp -r $PATH_2_STAGE/direct_deploy/catch2/lib $QNX_TARGET/x86_64/usr/local/
cp -r $PATH_2_STAGE/direct_deploy/catch2/share $QNX_TARGET/x86_64/usr/local/
```

# Build local lib and tests catch2
```bash
cd ~/qnx_workspace

# Clone catch2 from QNX fork
git clone https://github.com/qnx-ports/Catch2.git

# Or clone catch2 sources from original repo
git clone https://github.com/catchorg/Catch2.git

cd Catch2

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain for QNX target
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <profile-name>: nto-7.1-aarch64-le,  nto-7.1-x86_64,     nto-8.0-aarch64-le,  nto-8.0-x86_64
# <version-number>: 3.6.0, 2.13.10
#
# Usage [linux]:
#   conan install --version=<version-number> $QNX_CONAN_ROOT/recipes/catch2/tests
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/catch2/test
#
# Note: for debug build, use cmd option "-s build_type=Debug"
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=3.6.0 $QNX_CONAN_ROOT/recipes/catch2/tests

# Regenerate the amalgamated distribution (some tests are built against it)
# For version >= 3.6.0
./tools/scripts/generateAmalgamatedFiles.py

cmake --preset conan-release

# For systems with less than 48 GB of memory, limit parallel build jobs to 6.
cmake --build build_tests/Release --parallel 6
```

# Run tests on Linux
```bash
# Run the tests using CTest
ctest --output-on-failure --test-dir build_tests/Release
```

# Run tests on the QNX target.

Pre-requisite

* Create a QEMU image with Python installed, >2 GB data size, and >20K data inodes. [mkqnximage-docs]
* Build and install cmake [cmake-docs]

```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf catch2_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir catch2_tests"

# Copy lighttpd1.4 build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* qnxuser@$TARGET_HOST:/data/home/qnxuser/catch2_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/qnxuser/catch2_tests

# Fix absolute paths
python ./ctest.py

# Run the tests using CTest
ctest --test-dir build_tests/Release
```

# CTest for Catch2 version=3.6.0

* Most of the failed tests were caused by a missing compiler on the target system.
* ApprovalTests are failing because the build and target machines use different paths.

```bash
94% tests passed, 7 tests failed out of 118

Label Time Summary:
uses-python     =  14.07 sec*proc (13 tests)
uses-signals    =   0.07 sec*proc (1 test)

Total Test time (real) =  33.06 sec
```

# CTest for Catch2 version=2.13.10

* ApprovalTests are failing because the build and target machines use different paths.

```bash
97% tests passed, 1 tests failed out of 38

Total Test time (real) =   8.79 sec
```

[cmake-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/cmake/README.md
[mkqnximage-docs]: https://www.qnx.com/developers/docs/7.1/com.qnx.doc.neutrino.utilities/topic/m/mkqnximage.html?hl=mkqnximage
