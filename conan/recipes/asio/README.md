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
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
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

# Install asio headers

```bash
# Install headers into conan cache
#
# <version-number>: 1.29.0
#
# Usage [linux/QNX]:
#   conan create --version=<version-number> $QNX_CONAN_ROOT/recipes/asio/all
conan create --version=1.29.0 $QNX_CONAN_ROOT/recipes/asio/all
```

# Build QNX/Linux tests for asio

```bash
cd ~/qnx_workspace

# Clone asio sources from QNX repository
git clone https://github.com/qnx-ports/asio.git

# OR from asio official repository
git clone https://github.com/chriskohlhoff/asio

cd asio

# Setup project root folder
export QNX_PROJECT_ROOT=$(pwd)

# Install conan toolchain and build new asio tests
#
# <profile-name>: nto-7.1-aarch64-gcc, nto-7.1-x86_64-gcc, nto-8.0-aarch64-gcc, nto-8.0-x86_64-gcc
# <profile-name>: nto-7.1-aarch64,     nto-7.1-x86_64,     nto-8.0-aarch64,     nto-8.0-x86_64
# <version-number>: 1.29.0
#
# Usage [linux]:
#   conan install --version=<version-number> $QNX_CONAN_ROOT/recipes/asio/tests
# Usage [QNX and Linux]:
#   conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/<profile-name> --version=<version-number> $QNX_CONAN_ROOT/recipes/asio/tests
conan install -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=1.29.0 $QNX_CONAN_ROOT/recipes/asio/tests

conan build -pr:h=$QNX_CONAN_ROOT/tools/profiles/nto-8.0-x86_64 --version=1.29.0 $QNX_CONAN_ROOT/recipes/asio/tests
```

# Run tests on the QNX target.

```bash
# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf asio_tests"

# create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir asio_tests"

# copy asio tests and run script to your QNX target
scp -r build_tests/Release/* qnxuser@$TARGET_HOST:/data/home/qnxuser/asio_tests/
scp $QNX_CONAN_ROOT/recipes/asio/tests/run_tests.sh qnxuser@$TARGET_HOST:/data/home/qnxuser/asio_tests/

# ssh into the target
ssh qnxuser@$TARGET_HOST

# run asio tests
cd asio_tests
chmod +x run_tests.sh
./run_tests.sh
```
