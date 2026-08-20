# lmbench [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lmbench.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lmbench.yml)

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
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Clone lmbench
git clone https://github.com/qnx-ports/lmbench

# Build lmbench
make -C build-files/ports/lmbench install
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files
git clone https://github.com/qnx-ports/lmbench

# Build lmbench
make -C build-files/ports/lmbench install
```

# How to Run Tests/Benchmarks

Note: QDD QEMU (`com.qnx.qnx800.quickstart.qemu`) was used to perform tests.

```bash
export TARGET_IP=<target-ip-address-or-hostname>

# Move the test binaries and scripts to target
scp -r ~/qnx800/target/qnx/x86_64/usr/local/bin/qnx-x86_64 qnxuser@$TARGET_IP:~/
scp -r ~/qnx800/target/qnx/usr/local/scripts qnxuser@$TARGET_IP:~/

# Run the tests
cd ~/scripts
export OS=qnx-x86_64 (or qnx-aarch64 if running on aarch64 system)
./config-run (set the options in accordance or choose defaults)
./results (results will be available in results/ folder)
```
