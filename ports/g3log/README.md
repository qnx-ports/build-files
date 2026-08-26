# g3log [![Build](https://github.com/qnx-ports/build-files/actions/workflows/g3log.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/g3log.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Crash analysis tools already exist in QNX like pidin stack, dumpcrash, or gdb to analyze crashes.These are more powerful and integrated with the OS. Additionally execinfo is not available on QNX. Thus disabled stacktrace.

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use the maximum number of cores to build this project.

You can optionally set up a staging area folder (e.g. /tmp/staging) for <staging-install-folder> using `USE_INSTALL_ROOT=true` and INSTALL_ROOT_nto to <staging-install-folder> in below `make` command

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

# Clone g3log and googletest
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/g3log.git
git clone https://github.com/qnx-ports/googletest.git

# Build googletest
QNX_PROJECT_ROOT=$(pwd)/googletest make -C build-files/ports/googletest install JLEVEL=4
make -C build-files/ports/g3log install JLEVEL=4

```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/g3log.git
git clone https://github.com/qnx-ports/googletest.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build googletest
QNX_PROJECT_ROOT=$(pwd)/googletest make -C build-files/ports/googletest install JLEVEL=4

# Build g3log
make -C build-files/ports/g3log install JLEVEL=4

```

# Running tests

```bash
export TARGET_HOST=<target-ip-address-or-hostname>

# Copy the dependency libraries for testing

scp $QNX_TARGET/aarch64le/usr/local/lib/libg3log.so*   qnxuser@$TARGET_HOST:~/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libgtest* qnxuser@$TARGET_HOST:~/lib

# Copy test binaries abd script to target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/g3log_tests qnxuser@$TARGET_HOST:~/
scp $(pwd)/build-files/ports/g3log/test.sh qnxuser@$TARGET_HOST:~/
```

### On target run

```bash
chmod 755 test.sh
sh test.sh
```
