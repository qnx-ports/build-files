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

# LLVM is needed for rust build for all targets and host/cross compilation.
#
# <version-number>: 1.90.0
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/rust-llvm/all
conan create --version=1.90.0 $QNX_CONAN_ROOT/recipes/rust-llvm/all

# Rust is a host tool, built and install for a Linux host and Linux/QNX targets.
#
# <target-name-linux>: x86_64-unknown-linux-gnu <-- This is default target
# <target-name-qnx>: aarch64-unknown-nto-qnx710, x86_64-pc-nto-qnx710, aarch64-unknown-nto-qnx800, x86_64-pc-nto-qnx800
# <version-number>: 1.90.0
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/rust-toolchain/all
# Usage [QNX and Linux]:
#   conan create --version=<version-number> -o target=<target-name-[qnx/linux]> $QNX_CONAN_ROOT/recipes/rust-toolchain/all
conan create --version=1.90.0 -o target=x86_64-pc-nto-qnx800 $QNX_CONAN_ROOT/recipes/rust-toolchain/all
```

# Testing

All tests were done within standalone rust project.

See: [rust-conan-recipes] [rust-docs]

[rust-conan-recipes]: https://github.com/qnx-ports/build-files/conan/recipes/rust
[rust-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/rust/README.md
