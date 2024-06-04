**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/everywhere/qnx-ports.git && cd qnx-ports

# Build the Docker image and create a container
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone googletest
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/libs/googletest.git

# Build googletest
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C qnx-ports/googletest install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/everywhere/qnx-ports.git
git clone https://gitlab.com/qnx/libs/googletest.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C qnx-ports/googletest install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/bin/googletest_tests root@<target-ip-address>:/
scp $QNX_TARGET/aarch64le/usr/local/lib/libg* root@<target-ip-address>:/usr/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run unit tests
cd /googletest_tests
chmod +x *
./gmock-actions_test
```
