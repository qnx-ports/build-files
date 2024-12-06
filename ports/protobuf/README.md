# Compile the port for QNX

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

# Clone protobuf
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/protobuf.git && cd protobuf
git submodule update --init
git apply ~/qnx_workspace/build-files/ports/protobuf/qnx.patch
cd ~/qnx_workspace

# Build protobuf
[export INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA>]
[USE_INSTALL_ROOT=true] QNX_PROJECT_ROOT="$(pwd)/protobuf" make -C build-files/ports/protobuf install JLEVEL=4
```

# Compile the port for QNX
```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/protobuf.git

# Build numpy
cd protobuf
git submodule update --init
git apply ../build-files/ports/protobuf/qnx.patch
cd -

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build protobuf
[export INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA>]
[USE_INSTALL_ROOT=true] QNX_PROJECT_ROOT="$(pwd)/protobuf" make -C build-files/ports/protobuf install JLEVEL=4
```

# How to run tests

Create directories on the target.

Assuming your `INSTALL_ROOT_nto` is 

```bash
mkdir -p /data/home/qnxuser/protobuf/libs
````

Set up the test environment (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)
```bash
TARGET_HOST=<target-ip-address-or-hostname>
```
Now we copy protobuf test binaries and data to target. We need to first go to the correct directory.
If you used `INSTALL_ROOT_nto`, run 
```bash
cd $INSTALL_ROOT_nto/aarch64le/usr/local/
```

If you installed protobuf to SDP, run
```bash
cd $QNX_TARGET/aarch64le/usr/local/
```
**MAKE SURE YOU ARE AT THE CORRECT DIRECTORY**

```bash
scp ./bin/protoc* ./bin/test* qnxuser@$TARGET_HOST:/data/home/qnxuser/protobuf/
scp -r ./bin/src qnxuser@$TARGET_HOST:/data/home/qnxuser/protobuf/
scp ./lib/libabsl* ./lib/libproto* ./lib/libgmock* ./lib/libupb.a ./lib/libutf8* qnxuser@$TARGET_HOST:/data/home/qnxuser/protobuf/libs
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
cd /data/home/qnxuser/protobuf

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/protobuf/libs

./tests
```

# Known issues

The following test cases fail due to floating point number conversion issues:
```
[  FAILED  ] TextFormatTest.PrintFloatPrecision
[  FAILED  ] TextFormatTest.PrintFieldsInIndexOrder
```