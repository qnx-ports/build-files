# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

**NOTE** : Following port makes use of OpenMP by default. To disable it, add `USE_OPENMP=OFF` flag to the build command (refer below)

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

# Clone OpenBLAS
git clone https://github.com/qnx-ports/OpenBLAS.git

# Build OpenBLAS
QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/OpenBLAS.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build OpenBLAS
QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```
# How to run tests

Move the libraries and tests to the target
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move libraries to the target
scp -r $QNX_TARGET/x86_64/usr/local/lib/libopenblas* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/x86_64/lib/libgomp* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Move the test binaries to the target
scp -r $QNX_TARGET/x86_64/usr/local/bin/openblas_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
```

Run the tests
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Add lib folder to LD_LIBRARY_PATH variable
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

# Run tests
./openblas_utest
./openblas_utest_ext
sh openblas_ctest.sh
./dgemm_thread_safety
./dgemv_thread_safety
```
