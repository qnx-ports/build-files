# ceres-solver [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ceres-solver.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ceres-solver.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

# Compile ceres-solver for SDP7.1/8.0 on Ubuntu Host or in Docker container

Optional step requires Docker: https://docs.docker.com/engine/install

1. Create QNX workspace or navigate to one

```bash
mkdir qnx_workspace && cd qnx_workspace
```

2. Clone `ceres-solver` and dependencies

```bash

git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/muslflt.git
git clone https://github.com/qnx-ports/eigen.git
git clone -b https://github.com/ceres-solver/ceres-solver.git

# Optional dependencies of ceres-solver are listed below and available on qnx-ports
1. googletest
2. glog
3. METIS
4. OpenBLAS
5. SuiteSparse
```

3. _Optional_ Build the docker image and create a container

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

cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ install JLEVEL=4
QNX_PROJECT_ROOT="$(pwd)/eigen" make -C build-files/ports/eigen install JLEVEL=4
make -C build-files/ports/ceres-solver install -j4
```

# How to run tests and application

**NOTE**: Below steps are for running the tests on QNXE QSTI RPi4 image

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move the test binaries to the target
scp -r ~/qnx_workspace/build-files/ports/ceres-solver/nto-aarch64-le/build/bin/* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Move ceres-solver and dependent libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libceres.so* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libeigen.so* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Move test script to the target
scp ~/qnx_workspace/build-files/ports/ceres-solver/test.sh qnxuser@$TARGET_HOST:/data/home/qnxuser
```

Run the tests

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

cd ~/bin
./test.sh
```
