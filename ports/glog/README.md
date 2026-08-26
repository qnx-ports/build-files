# glog [![Build](https://github.com/qnx-ports/build-files/actions/workflows/glog.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/glog.yml)

### Tested for QNX 7.1 and 8.0 SDPs

Cross-compiled on Ubuntu 24.04 for:

- QNX 8.0 aarch64le on Raspberry Pi 4
- QNX 7.1 x86_64 on qemu

Instructions for compiling and running tests are listed below.

# Compile gflags for SDP 7.1/8.0 on an Ubuntu Host or in a Docker Container

Optionally requires Docker: https://docs.docker.com/engine/install/

1. Create a new workspace or navigate to a desired one

```bash
mkdir glog_wksp && cd glog_wksp
```

2. Clone the `glog` and `build-files` repos

```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/glog.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
git clone git@github.com:qnx-ports/glog.git
```

3. _Optional_ Build the Docker image and create a container

```bash
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
```

4. Source your SDP (Installed from QNX Software Center)

```bash
#QNX 8.0 will be in the directory ~/qnx800/
#QNX 7.1 will be in the directory ~/qnx710/
source ~/qnx800/qnxsdp-env.sh

#Navigate back to glog_wksp
#The docker container will put you in your home directory
cd <path-to-workspace>

```

5. _Dependancies_ Build dependancies. If you already have `googletest` and `gflags` installed and set up, skip this step.

```bash
## Cloning
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/googletest.git
git clone https://github.com/qnx-ports/gflags.git

#Via SSH
git clone git@github.com:qnx-ports/googletest.git
git clone git@github.com:qnx-ports/gflags.git


## Building
make -C build-files/ports/googletest install -j4
make -C build-files/ports/gflags install -j4
```

6. Build the project in your workspace from Step 1

```bash
#Navigate back to gflags_wksp
#The docker container will put you in your home directory
cd <path-to-workspace>

make -C build-files/ports/glog install -j4
```

**NOTE**: Prior to rebuilding, it is good practice to clean your build files. This is REQUIRED when switching between SDP variations (i.e. 8.0 -> 7.1)

```bash
#From your workspace:
make -C build-files/ports/glog clean
```

# Running Tests on a Target

Some distributions of QNX have critical directories stored in a read-only partition (`/`, `/system`, `/etc`, etc). Included in these are the default `bin` and `lib` directories. The instructions below install said libraries in a separate lib folder for this reason.

### Installation in home directory

1. Installation

```bash
## Setup environment variables
# Set your target's IP
TARGET_IP=<target-ip-address-here>
# Choose the user to install this for
TARGET_USER="qnxuser"
#Select the prefix you used when building
PREFIX="/usr/local"

## Create new directories on target
ssh $TARGET_USER@$TARGET_IP "mkdir -p /data/home/$TARGET_USER/glog/lib && mkdir -p /data/home/$TARGET_USER/glog/test"

## If copying to an x86_64 machine, switch aarch64le to x86_64
# Test Binaries, Scripts, Inputs
scp -r $QNX_TARGET/aarch64le/$PREFIX/bin/glog_tests/* $TARGET_USER@$TARGET_IP:/data/home/$TARGET_USER/glog/test

# Library .so files
#-> Match libglog, libgtest, libgmock, libgflag
scp $QNX_TARGET/aarch64le/$PREFIX/lib/libg[mtlf][oel][acsg]*.so* $TARGET_USER@$TARGET_IP:/data/home/$TARGET_USER/glog/lib
```

2. Running Tests

```bash
# SSH Into Target
ssh qnxuser@<target-ip-address-or-hostname>

# Export new library path
export export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/glog/lib

# Run test binaries
cd ~/glog/test         #NOTE: ~ will direct you to the current user's home directory,
                        #which may be incorrect depending on your choices above.
                        #Navigate to /data/home to see all user home directories
chmod 744 *
./run_tests.sh
```
