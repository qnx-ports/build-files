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

# Build and install release cmake for QNX into conan cache
```bash
cd ~/qnx_workspace

# Build lighttpd
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <version-number>: 1.4.73, 1.4.81
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/lighttpd1.4/all
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/lighttpd1.4/all
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc --version=1.4.73 $QNX_CONAN_ROOT/recipes/lighttpd1.4/all --build=missing
```

# Deploy lighttpd into QNX SDP
```bash
cd ~/qnx_workspace

mkdir stage_lighttpd

export LIGHTTPD_STAGE=$(realpath ~/qnx_workspace/stage_lighttpd)

# Copy lighttpd to stage folder
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <version-number>: 1.4.73, 1.4.81
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc \
    --requires=lighttpd1.4/1.4.73 \
    -d=direct_deploy \
    --deployer-folder=$LIGHTTPD_STAGE

# copy lighttpd into SDP
cp -r $LIGHTTPD_STAGE/direct_deploy/lighttpd1.4/bin $QNX_TARGET/x86_64/usr/local/
cp -r $LIGHTTPD_STAGE/direct_deploy/lighttpd1.4/lib $QNX_TARGET/x86_64/usr/local/
cp -r $LIGHTTPD_STAGE/direct_deploy/lighttpd1.4/share $QNX_TARGET/x86_64/usr/local/
```

# Build QNX tests for lighttpd

```bash
cd ~/qnx_workspace

# Clone sources from QNX repository
git clone https://github.com/qnx-ports/lighttpd1.4.git

# OR from github official repository
git clone https://github.com/lighttpd/lighttpd1.4.git

cd lighttpd1.4

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain for QNX target
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <version-number>: 1.4.73, 1.4.81
#
# Usage [linux]:
#   conan install --version=<version-number> $QNX_CONAN_ROOT/recipes/lighttpd1.4/tests
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/lighttpd1.4/test
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc --version=1.4.73 $QNX_CONAN_ROOT/recipes/lighttpd1.4/tests --build=missing

cmake --preset conan-release

cmake --build build_tests/Release -- -j
```

# Run tests on QNX target

Pre-requisite

* build and install cmake [cmake-docs]
* build and install perl5 [perl5-docs]

```bash
# Copy ctest.py to adjust paths in CTestTestfile.cmake
cp $QNX_CONAN_ROOT/tools/ctest.py $QNX_PROJECT_ROOT/

# Define target IP address
export TARGET_HOST=<target-ip-address-or-hostname>

# Setup perl env for test scripts
ssh root@$TARGET_HOST "ln -Ps /system/bin/env /usr/bin/env; ln -Ps /system/bin/perl /usr/bin/perl;"

# Remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf lighttpd1.4_tests"

# Create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir lighttpd1.4_tests"

# Copy lighttpd1.4 build tree to your QNX target
scp -r $QNX_PROJECT_ROOT/* qnxuser@$TARGET_HOST:/data/home/qnxuser/lighttpd1.4_tests/

# Ssh into the target
ssh qnxuser@$TARGET_HOST

# Add cmake to the PATH
export PATH=$PATH:/data/home/qnxuser/cmake/bin

cd /data/home/qnxuser/lighttpd1.4_tests

# Fix absolute paths
python ./ctest.py

cd ./build_tests/Release/

ctest
```
CTest for lighttpd1.4

### QNX8.0 x86_64 v1.4.73:
```bash
100% tests passed, 0 tests failed out of 9

Total Test time (real) =   1.38 sec
```

### QNX8.0 x86_64 v1.4.81:
```bash
100% tests passed, 0 tests failed out of 9

Total Test time (real) =   0.93 sec
```

[perl5-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/perl5/README.md
[cmake-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/cmake/README.md
