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

# Update conan setting
```bash
# Setup conan root folder.
export QNX_CONAN_ROOT=$(realpath ~/qnx_workspace/build-files/conan)
# Detect build profile if not already detected.
conan profile detect
# Update conan settings for QNX8.0 support
conan config install $QNX_CONAN_ROOT/tools/qnx-8.0-extension/settings_user.yml
```

# Build and install release Rust package for QNX into conan cache
```bash
cd ~/qnx_workspace
# Install rustup proper binaries host tool for a Linux
#
# <version-number>: 1.28.2
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/rustup/binary
conan create --version=1.28.2 $QNX_CONAN_ROOT/recipes/rustup/binary

# Rust is a host tool, built and install for a Linux host and Linux/QNX targets.
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
# <version-number>: 1.90.0
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/rust/all
# Usage [QNX and Linux]:
#   conan create --version=<version-number> -o target=<target-name> $QNX_CONAN_ROOT/recipes/rust/all
conan create --version=1.90.0 -o target=x86_64-pc-nto-qnx800 $QNX_CONAN_ROOT/recipes/rust/all
```

# Build specific version of the new toolchain

```bash
cd ~/qnx_workspace

# Clone rust from QNX fork
git clone https://github.com/qnx-ports/rust.git

cd rust

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Copy config.toml to the source folder
cp $QNX_CONAN_ROOT/recipes/rust/all/config.toml .

# Setup env for local build
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
#
# Usage [linux]:
#   conan install $QNX_CONAN_ROOT/recipes/rust/tests
# Usage [QNX]:
#   conan install -o target=<target-name> $QNX_CONAN_ROOT/recipes/rust/tests
conan install -o target=x86_64-pc-nto-qnx800 $QNX_CONAN_ROOT/recipes/rust/tests

# Build new rust toolchain
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
#
# Usage [linux]:
#   conan build $QNX_CONAN_ROOT/recipes/rust/tests
# Usage [QNX]:
#   conan build -o target=<target-name> $QNX_CONAN_ROOT/recipes/rust/tests
conan build -o target=x86_64-pc-nto-qnx800 $QNX_CONAN_ROOT/recipes/rust/tests
```

# Install new toolchain

```bash
# Source conan env for building
source ./build_toolchain/generators/conanbuild.sh

# Install new toolchain from build tree
rustup toolchain link new_toolchain build_toolchain/host/stage1
```

# Run tests on the new toolchain.

## Linux tests

``` bash
# Activate freshly built toolchain with new toolchain
rustup override set new_toolchain

# Clean up remote test server IP
unset TEST_DEVICE_ADDR

# Run linux UI tests
./x test tests/ui
```

## QNX remote target tests

``` bash
# Define QNX target IP address
export QNX_TARGET_HOST=<target-ip-address-or-hostname>

# Activate freshly built toolchain with new toolchain
rustup override set new_toolchain

# Build remote test server
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
#
# Usage:
#   ./x build remote-test-server --target <target-name>
./x build remote-test-server --target x86_64-pc-nto-qnx800

# Copy remote test server to the QNX target system
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
#
# Usage:
#   scp ./build/host/stage1-tools/<target-name>/release/remote-test-server root@$QNX_TARGET_HOST:/data/home/root/
scp ./build/host/stage1-tools/x86_64-pc-nto-qnx800/release/remote-test-server root@$QNX_TARGET_HOST:/data/home/root/

# Start remote test server on QNX target system
ssh root@$QNX_TARGET_HOST "/data/home/root/remote-test-server -v --bind 0.0.0.0:12345 > /dev/null 2>&1 &"

# OPTIONAL: you can check connection to remote test server
nc $QNX_TARGET_HOST 12345
# type ping
ping
# receive pong
pong

# Setup QNX target system IP for rust tests
export TEST_DEVICE_ADDR=$QNX_TARGET_HOST":12345"

# Build and run UI tests on the remote QNX target
#
# <target-name>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
#
# Usage:
#   ./x test tests/ui --target <target-name>
./x test tests/ui --target x86_64-pc-nto-qnx800 --force-rerun
```
