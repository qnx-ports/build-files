# g3log [![Build](https://github.com/qnx-ports/build-files/actions/workflows/g3log.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/g3log.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use the maximum number of cores to build this project.

# Setup a Docker container

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

# Clone g3log and googletest
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/g3log.git
git clone https://github.com/qnx-ports/googletest.git

#Build googletest
make -C build-files/ports/googletest install
make -C build-files/ports/g3log.git install

```


# Or setup Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/g3log.git
git clone https://github.com/qnx-ports/googletest.git

```

# Compile g3log and its tests for QNX
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

#Build googletest
make -C build-files/ports/googletest install

# Build g3log
BUILD_TESTING="ON" make -C build-files/ports/g3log install JLEVEL=$(nproc) [INSTALL_ROOT_nto=PATH_TO_YOUR_STAGING_AREA USE_INSTALL_ROOT=true]

```
# Running tests

```bash
#copy all the test binaries from the build folder (ex:build-files/ports/g3log/nto-aarch64-le/build/test_concept_sink)
#to target and execute those.

scp build-files/ports/g3log/nto-aarch64-le/build/test_concept_sink qnxuser@$TARGET_HOST:/data/home/qnxuser/

./test_concept_sink

```