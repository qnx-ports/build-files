# libyaml [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libyaml.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libyaml.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system
Supports QNX7.1 and QNX8.0

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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

# Clone libyaml
git clone https://github.com/qnx-ports/libyaml.git

# Build libyaml
QNX_PROJECT_ROOT="$(pwd)/libyaml" make -C build-files/ports/libyaml/ install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/libyaml.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build libyaml
QNX_PROJECT_ROOT="$(pwd)/libyaml" make -C build-files/ports/libyaml/ install -j4
```

# Tests

```bash
# scp `libyaml.so` and `libyaml_tests` to target
TARGET_IP_ADDRESS=<target-ip-address>
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/libyaml_tests qnxuser@$TARGET_IP_ADDRESS:/data/home/qnxuser/bin
scp ~/qnx800/target/qnx/aarch64le/usr/local/lib/libyaml.so qnxuser@$TARGET_IP_ADDRESS:/data/home/qnxuser/lib

# ssh
ssh qnxuser@$TARGET_IP_ADDRESS

# Run tests
cd bin/libyaml_tests
echo 'foo: bar' | ./run-parser-test-suite
./run-parser /system/etc/config/sensor/rpi5_algorithm_imx708.json
```
