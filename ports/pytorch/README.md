# Compile the port for QNX

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

## Build Pytorch Mobile in a Docker container

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone pytorch
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/pytorch.git

# Install pip dependencies
cd ~/qnx_workspace/pytorch
pip install -r requirements.txt

# Init submodules
git submodule update --init --recursive

# Apply third_party patches
cd ~/qnx_workspace/build-files/ports/pytorch
./scripts/patch.sh ~/qnx_workspace/pytorch

# Build pytorch mobile w/ lite interpreter
cd ~/qnx_workspace
export BUILD_PYTORCH_MOBILE_WITH_HOST_TOOLCHAIN=1
BUILD_TESTING=ON BUILD_LITE_INTERPRETER=ON QNX_PROJECT_ROOT="$(pwd)/pytorch" make -C build-files/ports/pytorch  install JLEVEL=4
```

## Build Pytorch Mobile on Host

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Clone pytorch
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/pytorch.git

# Create a python virtual environment and install necessary packages
python3.11 -m venv env
source env/bin/activate
cd ~/qnx_workspace/pytorch
pip install -r requirements.txt

# Init submodules
git submodule update --init --recursive

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Apply third_party patches
cd ~/qnx_workspace/build-files/ports/pytorch
./scripts/patch.sh ~/qnx_workspace/pytorch

# Build pytorch mobile w/ lite interpreter
cd ~/qnx_workspace
export BUILD_PYTORCH_MOBILE_WITH_HOST_TOOLCHAIN=1
BUILD_TESTING=ON BUILD_LITE_INTERPRETER=ON QNX_PROJECT_ROOT="$(pwd)/pytorch" make -C build-files/ports/pytorch  install JLEVEL=4
```

## Pytorch Mobile Build Options
See example https://pytorch.org/tutorials/prototype/lite_interpreter.html
```bash
BUILD_LITE_INTERPRETER=<ON|OFF>
SELECTED_OP_LIST=<path-to-yaml-file>
TRACING_BASED=<ON|OFF>
USE_LIGHTWEIGHT_DISPATCH=<ON|OFF> # Note, build will not succeed without setting SELECTED_OP_LIST.
```

## Run tests

**NOTE** There are other test binaries but they require you to do a custom build with the options specified above.

Move files to the target (note, mDNS is configured from /boot/qnx_config.txt and
uses qnxpi.local by default):
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/bin/*_test qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/lib/libc10.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/lib/libtorch_cpu.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/lib/libtorch_global_deps.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/lib/libtorch.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

Run unit tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
cd /data/home/qnxuser/bin
for test in $(ls | grep _test) ; do
    ./$test
done
```

Known lite interpreter test failures:
```
typeid_test - CtorDtorAndCopy (aborts)
```
