**NOTE**: QNX ports are only supported from a Linux host operating system

**WARNING**: Ruy is currently used as a dependency of tensorflow, and you shouldn't expect it working when building it solely.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# Build the Docker image and create a container
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone ruy
cd ~/qnx_workspace
git clone git@gitlab.com:qnx/ports/ruy.git

# Build ruy
QNX_PROJECT_ROOT="$(pwd)/ruy" make -C build-files/ruy install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/ruy.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build ruy
QNX_PROJECT_ROOT="$(pwd)/ruy" make -C build-files/ruy install -j$(nproc)
```

# How to run tests
