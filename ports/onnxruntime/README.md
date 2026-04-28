# onnxruntime

**NOTE**: QNX ports are only supported from Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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

# Install dependencies
./build-files/ports/onnxruntime/install_all.sh
git clone -b qnx-v1.23.2 https://github.com/microsoft/onnxruntime && cd onnxruntime
git submodule update --init
cd -

# Build onnxruntime
make -C build-files/ports/onnxruntime install -j12
```

# Compile the port for QNX on Ubuntu Host

```bash
# Source qnxsdp-env.sh in
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Install dependencies
./build-files/ports/onnxruntime/install_all.sh
git clone -b qnx-v1.23.2 https://github.com/microsoft/onnxruntime && cd onnxruntime
git submodule update --init
cd -

# Build onnxruntime
make -C build-files/ports/onnxruntime install -j12
```

# How to Run Tests and Applications

**NOTE**: Tests are performed on RPi4 target available via QNX-E

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib qnxuser@$TARGET_HOST:~/lib

# Move test files to the target
scp -r build-files/ports/onnxruntime/nto-aarch64-le/build qnxuser@$TARGET_HOST:~/
```

Run the tests

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib
cd build
./onnxruntime_test_all
```
