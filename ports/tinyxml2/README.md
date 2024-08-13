**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone ComputeLibrary
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/tinyxml2.git

# Build tinyxml2
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/tinyxml2" make -C build-files/ports/tinyxml2 install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/tinyxml2.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build tinyxml2
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/tinyxml2" make -C build-files/ports/tinyxml2 install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp -r $QNX_TARGET/aarch64le/usr/local/bin/tinyxml2_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp $QNX_TARGET/aarch64le/usr/local/lib/libtiny* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run xmltest
cd /data/home/qnxuser/bin/tinyxml2_tests
./xmltest
```
