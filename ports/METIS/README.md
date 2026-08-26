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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone metis
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/METIS.git

# Clone GKlib
cd ~/qnx_workspace
git clone https://github.com/KarypisLab/GKlib.git && cd GKlib
# Checkout latest tested commit
git checkout 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
git apply ~/qnx_workspace/build-files/ports/METIS/patches/GKlib.patch

# Build metis
cd ~/qnx_workspace
GKLIB_SRC="$(pwd)/GKlib" QNX_PROJECT_ROOT="$(pwd)/METIS" make -C build-files/ports/METIS install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/METIS.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Clone GKlib
cd ~/qnx_workspace
git clone https://github.com/KarypisLab/GKlib.git && cd GKlib
# Checkout latest tested commit
git checkout 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
git apply ~/qnx_workspace/build-files/ports/METIS/patches/GKlib.patch

# Build
cd ~/qnx_workspace
make -C build-files/ports/METIS install -j4
```

# How to run tests

METIS does not have its own test suite. To test the port you will have to rely on
the tests provided by other ports that use or provide a wrapper around METIS:

- gtsam - To test METIS, please refer to the gtsam build instructions, checkout
  the qnx_v4.1.1_SYSTEM_METIS branch, and build its tests with
  USE_SYSTEM_METIS=ON.
