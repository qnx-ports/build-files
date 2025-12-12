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
```

# Build and install release Rust package for QNX into conan cache
```bash
cd ~/qnx_workspace

# LLVM is needed for rust build for all targets and host/cross compilation.
#
# <version-number>: 1.90.0
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/rust-llvm/all
conan create --version=1.90.0 $QNX_CONAN_ROOT/recipes/rust-llvm/all
```

# Testing

All tests were done within standalone rust project.

See: [rust-conan-recipes] [rust-docs]

[rust-conan-recipes]: https://github.com/qnx-ports/build-files/conan/recipes/rust
[rust-docs]: https://github.com/qnx-ports/build-files/blob/main/conan/recipes/rust/README.md
