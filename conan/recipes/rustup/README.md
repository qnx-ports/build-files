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
mkdir -p ~/rustup_workspace && cd ~/rustup_workspace
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

# Setup conan env
```bash
# Setup conan root folder
export QNX_CONAN_ROOT=$(realpath ~/rustup_workspace/build-files/conan)
```

# Install release rustup into conan cache
```bash
# IMPORTANT: Linux only
#
# <version-number>: 1.28.2
#
# Usage [linux]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/rustup/binary
conan create --version=1.28.2 $QNX_CONAN_ROOT/recipes/rustup/binary
```
