# sscep [![Build](https://github.com/qnx-ports/build-files/actions/workflows/sscep.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/sscep.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Source qnxsdp-env.sh in
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Clone sscep and openssl-companion
git clone --recurse-submodules -b qnx-openssl-3.5.4 https://github.com/qnx-ports/openssl-companion.git
git clone https://github.com/qnx-ports/sscep.git

# Build openssl
mkdir -p install_ssl
make -C openssl-companion/build/Make install JLEVEL=4 INSTALL_ROOT_nto=$(pwd)/install_ssl USE_INSTALL_ROOT=true

# Build sscep
USE_CUSTOM_SSL=true make -C build-files/ports/sscep install JLEVEL=4 [default SSL path is $(pwd)/install_ssl; USE_IOSOCK=true to enable io-sock]
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
git clone https://github.com/qnx-ports/build-files.git
git clone --recurse-submodules -b qnx-openssl-3.5.4 https://github.com/qnx-ports/openssl-companion.git
git clone https://github.com/qnx-ports/sscep.git

# Build openssl
mkdir -p install_ssl
make -C openssl-companion/build/Make install JLEVEL=4 INSTALL_ROOT_nto=$(pwd)/install_ssl USE_INSTALL_ROOT=true

# Build sscep
USE_CUSTOM_SSL=true make -C build-files/ports/sscep install JLEVEL=4 [default SSL path is $(pwd)/install_ssl; USE_IOSOCK=true to enable io-sock]
```

# How to run application

sscep is a client side application. The repository does not have any tests. specific sscep operations can be tested by either hitting a public SCEP server or setting up a local SCEP server and querying it.
