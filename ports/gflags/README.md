# gflags [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gflags.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gflags.yml)

### Tested for QNX 7.1 and 8.0 SDPs

Cross-compiled on Ubuntu 24.04 for:

- QNX 8.0 aarch64le on Raspberry Pi 4
- QNX 7.1 x86_64 on qemu

Instructions for compiling and running tests are listed below.

# Compile gflags for SDP 7.1/8.0 on an Ubuntu Host or in a Docker Container

Optional step requires Docker: https://docs.docker.com/engine/install/

1. Create a new workspace or navigate to a desired one

```bash
mkdir gflags_wksp && cd gflags_wksp
```

2. Clone the `gflags` and `build_files` repos

```bash
#Pick one:
#Via HTTPS
git clone https://github.com/qnx-ports/build-files.git
git clone -b v2.2.2 https://github.com/gflags/gflags.git

#Via SSH
git clone git@github.com:qnx-ports/build-files.git
git clone -b v2.2.2 git@github.com:gflags/gflags.git
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
```

5. Build the project in your workspace from Step 1

```bash

#Navigate back to gflags_wksp
#The docker container will put you in your home directory
cd <path-to-workspace>

make -C build-files/ports/gflags install -j4

```

**NOTE**: Prior to rebuilding, it is good practice to clean your build files. This is REQUIRED when switching between SDP variations (i.e. 8.0 -> 7.1)

```bash
#From your workspace:
make -C build-files/ports/gflags clean
```

# Running Tests on a Target

Some distributions of QNX have critical directories stored in a read-only partition (`/`, `/system`, `/etc`, etc). Included in these are the default `bin` and `lib` directories. The instructions below install said libraries in a separate lib folder for this reason.

### Installing in home directory

1. Installation

```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>

#Select the home directory to install to (this will install to /data/home/qnxuser)
TARGET_USER_FOR_INSTALL="qnxuser"

#Select the workspace you made in step 1 of building
PATH_TO_YOUR_WORKSPACE="/path/to/your/workspace"

#Create new directories on the target
ssh $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/gflags/lib"
ssh $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS "mkdir -p /data/home/$TARGET_USER_FOR_INSTALL/gflags/test"

#If copying to an x86_64 install, change /aarch64le/ to /x86_64/
# Test Binaries
scp $QNX_TARGET/aarch64le/usr/bin/gflags_tests/* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gflags/test
scp $QNX_TARGET/aarch64le/usr/bin/gflags_tests/bin/* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gflags/test
# Library .so files
scp $QNX_TARGET/aarch64le/usr/lib/libgflags* $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gflags/lib
# Test script
scp $PATH_TO_YOUR_WORKSPACE/build-files/ports/gflags/qnxtest.sh $TARGET_USER_FOR_INSTALL@$TARGET_IP_ADDRESS:/data/home/$TARGET_USER_FOR_INSTALL/gflags/test
```

2. Running Tests

```bash
#SSH into target
ssh qnxuser@<target-ip-address-or-hostname>

#Export new library path (Change qnxuser to whatever you set for TARGET_USER_FOR_INSTALL)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/gflags/lib

#Run test binary
cd ~/gflags/test        #NOTE: ~ will direct you to the current user's home directory,
                        #which may be incorrect depending on your choices above.
                        #Navigate to /data/home to see all user home directories
chmod 744 gflag_*
./qnxtest.sh
```
