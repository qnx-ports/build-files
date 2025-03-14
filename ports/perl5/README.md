# perl5 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/perl5.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/perl5.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/perl5.git
git clone https://github.com/qnx-ports/perl-cross.git
```

# Sync perl-cross project into perl5 main tree
```bash
cd ~/qnx_workspace
# copy perl-cross build stuff into perl build tree
rsync -a --force --exclude='.git*' ./perl-cross/ ./perl5/
```

# Setup a Docker container

Pre-requisite:

* Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)

```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Compile the port for QNX
```bash
cd ~/qnx_workspace
# Build perl
make -C build-files/ports/perl5 JLEVEL=$(nproc)
# Install it in sysroot (QNX SDP)
make -C build-files/ports/perl5 install
# Or install it in a staging area
make -C build-files/ports/perl5 install INSTALL_ROOT_nto=<PATH_TO_YOUR_STAGING_AREA> USE_INSTALL_ROOT=true
```

# How to run tests
Build perl5 tests and scp it to the target.

**IMPORTANT** perl build tree needs **space** > 500Mb on data partition and **inodes** > 20k
### For example: mkqnximage --type=qemu --arch=x86_64 --clean --run --force --data-size=500 --data-inodes=20000
```bash
cd ~/qnx_workspace
# Build perl and all tests
make -C build-files/ports/perl5 JLEVEL=$(nproc)

# define target IP address
TARGET_HOST=<target-ip-address-or-hostname>

# remove old test dir on target
ssh qnxuser@$TARGET_HOST "rm -rf perl5_tests"

# create new test dir on target
ssh qnxuser@$TARGET_HOST "mkdir perl5_tests"

# copy perl build tree to your QNX target
scp -r build-files/ports/perl5/nto-aarch64-le/* qnxuser@$TARGET_HOST:/data/home/qnxuser/perl5_tests/
# or
scp -r build-files/ports/perl5/nto-x86_64-o/* qnxuser@$TARGET_HOST:/data/home/qnxuser/perl5_tests/
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# setup perl env
cd /data/home/qnxuser/perl5_tests/t && ln -sf ../perl . && LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH

# run perl tests
./perl harness
# or
./TEST
```

**Note**: Some tests are failed, less then 3% out of all.

### aarch64le ????:
#TODO run tests on aarch64
```bash
# put here aarch64 tests summary
```

### x86_64:
```bash
Failed 66 tests out of 2381, 97.23% okay.
...
Elapsed: 1003 sec
u=6.12  s=0.00  cu=431.71  cs=0.00  scripts=2381  tests=959363
```
