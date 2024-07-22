**NOTE**: QNX ports are only supported from a Linux host operating system

**WARNING**: Cpuinfo is currently used as a dependency of tensorflow, and you shouldn't expect it working when building it solely.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Build the Docker image and create a container
git clone https://gitlab.com/qnx/ports/docker-build-environment.git && cd docker-build-environment
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone cpuinfo
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/cpuinfo.git

# Build cpuinfo
QNX_PROJECT_ROOT="$(pwd)/cpuinfo" make -C build-files/cpuinfo install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/cpuinfo.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build cpuinfo
QNX_PROJECT_ROOT="$(pwd)/cpuinfo" make -C build-files/cpuinfo install -j$(nproc)
```

# How to run tests
