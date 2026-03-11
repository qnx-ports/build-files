# Compile the port for QNX
# dnsmasq [![Build](https://github.com/qnx-ports/build-files/actions/workflows/dnsmasq.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/dnsmasq.yml)

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

# Clone dnsmasq
git clone https://github.com/qnx-ports/dnsmasq.git
cd dnsmasq
git checkout qnx-v2.92
cd ..

# Build dnsmasq
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq clean 
# use below command for SDP8
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
# use below command for SDP7.1
# install io_sock from software center before building 
USE_IOSOCK=true QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone dnsmasq
git clone https://github.com/qnx-ports/dnsmasq.git
cd dnsmasq
git checkout qnx-v2.92
cd ..

# Build dnsmasq
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq clean 
# use below command for SDP8
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
# use below command for SDP7.1
# install io_sock from software center before building 
USE_IOSOCK=true QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
```

