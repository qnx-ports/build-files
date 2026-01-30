# trompeloeil [![Build](https://github.com/qnx-ports/build-files/actions/workflows/trompeloeil.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/trompeloeil.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone trompeloeil
git clone https://github.com/rollbear/trompeloeil.git
cd trompeloeil
git git checkout v49
cd ..

# Build trompeloeil
QNX_PROJECT_ROOT="$(pwd)/trompeloeil" make -C build-files/ports/trompeloeil/  install
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone trompeloeil
git clone https://github.com/rollbear/trompeloeil.git
cd trompeloeil
git git checkout v49
cd ..

# Build trompeloeil
QNX_PROJECT_ROOT="$(pwd)/trompeloeil" make -C build-files/ports/trompeloeil/  install
```


# Testing :

After building trompeloeil for your QNX target, validation is straightforward. The make process already compiles test binaries and copies test data to the CPU-specific directory (nto-<cpudir>). Deploy and run tests on your target device (RPi/x86 QNX machine).

Prerequisites:
    1. Built trompeloeil artifacts in build-files/ports/trompeloeil/nto-<cpudir>/
    2. Write permissions on target /tmp (or use TMPDIR=/fs/hd0/temp)
    3. SSH access to target device

1. Deploy to Target Device
```bash
TARGET_HOST=<target-ip-or-hostname>

# Copy entire CPU directory to target
scp -r ./build-files/ports/trompeloeil/nto-aarch64-le qnxuser@$TARGET_HOST:/home/qnxuser/guests/
```
2. SSH to Target and Setup Environment
```bash
ssh qnxuser@<TARGET_HOST>
cd /home/qnxuser/guests/nto-aarch64-le
```
3. Run Validation Tests
```bash
# Execute full test suite
./test/self_test && ./test/thread_terror && ./test/custom_recursive_mutex
```
4. Expected Results
```text
===============================================================================
All tests passed (1361 assertions in 604 test cases)

calls   244729 62225 53971 73347 61286 52905 51537 
returns 244729 62225 53971 73347 61286 52905 51537 
Pass! (the program compiled)
```