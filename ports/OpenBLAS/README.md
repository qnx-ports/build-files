# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true with the build command.

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
QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ install -j4
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
QNX_PROJECT_ROOT="$(pwd)/OpenBLAS" make -C build-files/ports/OpenBLAS/ install -j4
```

# How to run tests

**NOTE**: If you build the project with default configurations, transfer of `libgomp` to the target is required (as shown below). Otherwise, you may skip it's transfer.

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libopenblas* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/aarch64le/lib/libgomp* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Move the test binaries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/openblas_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
```

Run the tests

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Add lib folder to LD_LIBRARY_PATH variable
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

# Run tests
# You can either run the following tests one by one like
./openblas_utest
./openblas_utest_ext
sh openblas_ctests.sh
./dgemm_thread_safety
./dgemv_thread_safety

# Or you can transfer the qnxtests.sh file from build-files/ports/OpenBLAS to target's test folder and run it using
sh qnxtests.sh
```
