# PyTorch [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pytorch.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pytorch.yml)

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

# Note, main and v2.3.1 support SDP 8.0, v1.13.0 supports SDP 7.1
VERSION=main
BASELINE=~/qnx800

# Now you are in the Docker container

# Clone pytorch
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/pytorch.git && cd pytorch
git checkout qnx_$VERSION

# Install pip dependencies
pip install -r requirements.txt

# Init submodules
git submodule update --init --recursive

source $BASELINE/qnxsdp-env.sh

# Apply third_party patches
cd ~/qnx_workspace/build-files/ports/pytorch
./scripts/$VERSION/patch.sh $(pwd)/patches/$VERSION ~/qnx_workspace/pytorch

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

# Note main and v2.3.1 supports SDP 8.0, v1.13.0 supports SDP 7.1
VERSION=main
BASELINE=~/qnx800

# Clone pytorch
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/pytorch.git && cd pytorch
git checkout qnx_$VERSION

# Create a python virtual environment and install necessary packages
python3.11 -m venv env
source env/bin/activate
pip install -r requirements.txt

# Init submodules
git submodule update --init --recursive

source $BASELINE/qnxsdp-env.sh

# Apply third_party patches
cd ~/qnx_workspace/build-files/ports/pytorch
./scripts/$VERSION/patch.sh $(pwd)/patches/$VERSION ~/qnx_workspace/pytorch

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
**NOTE** The v1.13.0 build enables some benchmarks as well.

Move files to the target (note, mDNS is configured from /boot/qnx_config.txt and
uses qnxpi.local by default):
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/bin/*_test qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp ~/qnx_workspace/build-files/ports/pytorch/nto-aarch64-le/build/lib/*.so* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

Run unit tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

login root

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

# Run tests
cd /data/home/qnxuser/bin
for test in $(ls | grep _test) ; do
    ./$test
done
```

Known lite interpreter test failures for PyTorch main and v2.3.1 on SDP 8.0:
```
typeid_test - CtorDtorAndCopy (aborts)
```

Known lite interpreter test failures for PyTorch v1.13.0 on SDP 7.1:
```
./c10_typeid_test
[ RUN      ] TypeMetaTest.Names
/home/eleir/gh_workspace/pytorch/c10/test/util/typeid_test.cpp:32: Failure
Expected equality of these values:
  "nullptr (uninitialized)"
    Which is: 3138b430d0
  null_meta.name()
    Which is: {}
[  FAILED  ] TypeMetaTest.Names (21 ms)
```
