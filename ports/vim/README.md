# vim [![Build](https://github.com/qnx-ports/build-files/actions/workflows/vim.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/vim.yml)

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

## Build vim in a Docker container

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

# Clone vim
cd ~/qnx_workspace
git clone https://github.com/vim/vim.git && cd vim
git checkout v9.1.1115

# Build vim
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/vim" make -C build-files/ports/vim install JLEVEL=4
```

## Build vim on Host

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Install build tools
sudo apt install automake pkg-config

# Clone vim
cd ~/qnx_workspace
git clone https://github.com/vim/vim.git && cd vim
git checkout v9.1.1115

# Build vim
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/vim" make -C build-files/ports/vim install JLEVEL=4
```

## Run tests

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
