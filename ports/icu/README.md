# ICU (Internet Components for Unicode) [![Build](https://github.com/qnx-ports/build-files/actions/workflows/icu.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/icu.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone icu from upstream
cd ~/qnx_workspace
git clone https://github.com/unicode-org/icu.git

# Build icu
QNX_PROJECT_ROOT="$(pwd)/icu" JLEVEL=4 make -C build-files/ports/icu install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/unicode-org/icu.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build icu
QNX_PROJECT_ROOT="$(pwd)/icu" JLEVEL=4 make -C build-files/ports/icu install
``` 

# Deploy binaries via SSH
```bash
#Set your target's IP here
export TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
export TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin $TARGET_USER@$TARGET_IP_ADDRESS:~
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib $TARGET_USER@$TARGET_IP_ADDRESS:~
```

# Tests
Currently all tests are passed.
Tests are availale; to build and install tests, add enviroment variable `MAKE_BUILD_TEST=true` or excute the command below instead.
```bash
QNX_PROJECT_ROOT="$(pwd)/icu" MAKE_BUILD_TEST=true JLEVEL=4 make -C build-files/ports/icu install
```
To run tests, make sure you have deployed all binaries as root and running them as root
```bash
# 1, add ~/lib to LD_LIBRARY_PATH as root
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/lib

# 2, copy or move test datas into /var
cp -r ~/bin/icu_tests /var
cp -r ~/bin/testdata /var

# 3, navigate into icu_tests
cd /var/icu_tests

# 4, excute the test program
./cintltst | tee cintltst.result
./iotest | tee iotest.result
./intltst | tee intltst.result
```