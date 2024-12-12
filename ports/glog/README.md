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

3. *Optional* Build the Docker image and create a container
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

5. *Dependancies* Build dependancies. If you already have `googletest` and `gflags` installed and set up, skip this step. 
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
PREFIX="/usr/local" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/gflags install -j4
PREFIX="/usr/local" OSLIST="nto" QNX_PROJECT_ROOT="$(pwd)/gflags" make -C build-files/ports/gflags install -j4
```

6. Build the project in your workspace from Step 1
```bash
#Navigate back to gflags_wksp
#The docker container will put you in your home directory
cd <path-to-workspace>

PREFIX="/usr/local" OSLIST="nto" QNX_PROJECT_ROOT="$(pwd)/gflags" make -C build-files/ports/gflags install -j4
```

**NOTE**: Prior to rebuilding, it is good practice to clean your build files. This is REQUIRED when switching between SDP variations (i.e. 8.0 -> 7.1)

```bash
#From your workspace:
make -C build-files/ports/glog clean
```

# Running Tests on a Target
--TODO--