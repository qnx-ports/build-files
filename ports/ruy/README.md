**NOTE**: QNX ports are only supported from a Linux host operating system

**WARNING**: Ruy is currently used as a dependency of tensorflow, and you shouldn't expect it working when building it solely.

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

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

# Clone ruy
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/ruy.git && cd ruy
git submodule update --init --recursive
cd -

# Build ruy
QNX_PROJECT_ROOT="$(pwd)/ruy" make -C build-files/ports/ruy install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/ruy.git && cd ruy
git submodule update --init --recursive
cd -

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build ruy
QNX_PROJECT_ROOT="$(pwd)/ruy" make -C build-files/ports/ruy install -j4
```

# How to run tests
