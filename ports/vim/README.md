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

**NOTE** This port has many features disabled so we can't guarrantee full test
support.

Move files to the target (note, mDNS is configured from /boot/qnx_config.txt and
uses qnxpi.local by default):
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# scp vim to the target
scp $QNX_TARGET/aarch64le/usr/local/bin/vim qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp -r $QNX_TARGET/usr/local/share/vim qnxuser@$TARGET_HOST:/data/home/qnxuser

# scp tests to the target
scp -r ~/qnx_workspace/build-files/ports/vim/nto-aarch64-le/build/src qnxuser@$TARGET_HOST:/data/home/qnxuser
```

Run unit tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Install vim
su root -c mv bin/vim /system/bin
su root -c mv vim /system/share

# Run tests
cd src/testdir
for test in $(ls test_*.vim); do vim -u NONE -S runtest.vim $test; done
```

The test results will be written to `/data/home/qnxuser/testdir/messages`
