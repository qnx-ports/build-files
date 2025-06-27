# uProtocol [![Build](https://github.com/qnx-ports/build-files/actions/workflows/uProtocol.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/uProtocol.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/up-conan-recipes.git
git clone https://github.com/qnx-ports/up-cpp.git
```

# Setup a Docker container

Pre-requisite:

* Install Docker on Ubuntu
   - https://docs.docker.com/engine/install/ubuntu/
* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)
   - https://www.qnx.com/products/everywhere/ (**Non-Commercial Use**)
* Install venv - recomended by conan documentation - OPTIONAL
￼  - https://docs.python.org/3/library/venv.html
* Install Conan2
  - https://docs.conan.io/2/installation.html

```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Compile the port for QNX
```bash
cd ~/qnx_workspace
# Build uProtocol packages
cd up-conan-recipes

# build protobuf for Linux build machine
conan create --version=3.21.12 --build=missing protobuf

# IMPORTANT
# update conan settings for QNX8.0 support
conan config install tools/qnx-8.0-extension/settings_user.yml

# build protobuf for QNX host
#
# <profile-name> could be one of: nto-7.1-aarch64-le, nto-7.1-x86_64, nto-8.0-aarch64-le, nto-8.0-x86_64
#
conan create -pr:h=tools/profiles/<profile-name> --version=3.21.12 protobuf

# build up-core-api
conan create -pr:h=tools/profiles/<profile-name> --version 1.6.0-alpha2 up-core-api/release/

# build all dependencies for up-cpp
conan create -pr:h=tools/profiles/<profile-name> --version=10.2.1 fmt/all
conan create -pr:h=tools/profiles/<profile-name> --version=1.13.0 spdlog/all
conan create -pr:h=tools/profiles/<profile-name> --version=1.13.0 gtest

# build up-cpp
conan create -pr:h=tools/profiles/<profile-name> --version 1.0.1-qnx up-cpp/release
```

# How to run tests

Build and run up-cpp tests.

```bash
cd ~/qnx_workspace
# Build up-cpp tests
cd up-cpp

# setup cmake generator and preset for up-cpp
conan install -pr:h=../up-conan-recipes/tools/profiles/<profile-name> --version 1.0.1 .

# setup cmake configuration
cmake --preset conan-release

# build up-cpp libary and tests
cmake --build build/Release -- -j

# all tests you can find under build/Release/bin/
# copy test binaries to your QNX target
```
