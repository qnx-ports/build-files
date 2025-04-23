# pcre2 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pcre2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pcre2.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly

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

# Clone pcre2
cd ~/qnx_workspace
git clone https://github.com/PCRE2Project/pcre2.git

# check out to pcre2-10.45
cd pcre2
git checkout pcre2-10.45
cd ..

# Build pcre2
QNX_PROJECT_ROOT="$(pwd)/pcre2" JLEVEL=4 make -C build-files/ports/pcre2 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/PCRE2Project/pcre2.git

# check out to pcre2-10.45
cd pcre2
git checkout pcre2-10.45
cd ..

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build pcre2
QNX_PROJECT_ROOT="$(pwd)/pcre2" JLEVEL=4 make -C build-files/ports/pcre2 install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/pcre2* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libpcre2* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If `~/bin` or `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are avaliable; Test related to `locale` are failing due to the lack of support in QNX image
Make sure you have all required binaries deployed metioned above
```bash
# copy the test data
scp -r pcre2/testdata $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
# copy the test scripts
scp -r build-files/ports/pcre2/nto-aarch64-le/build/pcre2_test.sh $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r pcre2/RunTest $TARGET_USER@$TARGET_IP_ADDRESS:~/bin

# ssh to your target system 
ssh $TARGET_USER@$TARGET_IP_ADDRESS

# enter the bin directory and run the tests
sh ./RunTest
````