# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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

# Source qnxsdp-env.sh in
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Clone jansson
git clone https://github.com/qnx-ports/jansson.git

# Build jansson
make -C build-files/ports/jansson/ install -j4
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/jansson.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh

# Build jansson
make -C build-files/ports/jansson/ install -j4
```

# How to Run Tests

**NOTE**: QNX on RPi4 is used to perform the tests and report results.

Move the libraries, test binaries and script to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move libraries to the target
scp $QNX_TARGET/aarch64le/usr/local/lib/libjansson* qnxuser@$TARGET_HOST:~/lib

# Move the test binaries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/jansson_tests qnxuser@$TARGET_HOST:~/

cd ~/qnx_workspace
scp build-files/ports/jansson/qnxtests.sh qnxuser@$TARGET_HOST:~/jansson_tests
```

Run the tests

```bash
ssh qnxuser@$TARGET_HOST

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

cd jansson_tests
sh qnxtests.sh
```

Known test failures

- Only four tests should fail:
  - valid/real-exponent test by json_process, without and with --strip
  - valid/real-subnormal-number by json_process, without and with --strip
- Failures are related to floating point operations precision
