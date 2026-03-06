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

# Build and install release Iperf2 for QNX into conan cache
```bash
cd ~/qnx_workspace

#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <version-number>: 2.0.13, 2.1.4, 2.1.7, 2.1.9, 2.2.1
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf2/all
# Usage [QNX]:
#   conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf2/all
#
conan create -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc --version=2.2.1 $QNX_CONAN_ROOT/recipes/iperf2/all
```

# Deploy iperf2
```bash
cd ~/qnx_workspace

mkdir stage_iperf2

PATH_2_STAGE=$(realpath ~/qnx_workspace/stage_iperf2)

# deploy iperf2 to the stage folder
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc \
    --requires=iperf2/2.2.1 \
    --deployer=direct_deploy \
    --deployer-folder=$PATH_2_STAGE

# copy iperf2 into SDP
cp -r $PATH_2_STAGE/direct_deploy/iperf2/usr/* $QNX_TARGET/x86_64/usr/
```

# Build local iperf2
```bash
cd ~/qnx_workspace

# Clone iperf2 from QNX fork
git clone https://github.com/qnx-ports/iperf2.git

# Or clone iperf2 sources from original repo
git clone https://git.code.sf.net/p/iperf2/code iperf2

cd iperf2

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Setup env for local build
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
#
# Usage [linux]:
#   conan install --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf2/all
# Usage [QNX]:
#   conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf2/all
#
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc $QNX_CONAN_ROOT/recipes/iperf2/tests

# Build local iperf2
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
#
# Usage [linux]:
#   conan build --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf2/all
# Usage [QNX]:
#   conan build -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/iperf2/all
#
conan build -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64-gcc $QNX_CONAN_ROOT/recipes/iperf2/tests
```

# Run tests on the target.

```bash
# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# copy iperf2 and tests script to your QNX target
scp build_local/Release/src/iperf qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp $QNX_CONAN_ROOT/recipes/iperf2/tests/iperf2_tests.sh qnxuser@$TARGET_HOST:/data/home/qnxuser/

# ssh into the target
ssh qnxuser@$TARGET_HOST

# run iperf2 tests
chmod +x iperf2_tests.sh
./iperf2_tests.sh
