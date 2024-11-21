# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone Fast-CDR
git clone https://github.com/qnx-ports/Fast-CDR

# Add git submodules
NOTE: In case you do not want to build the test, you can skip this submodule addition part as well as set the BUILD_TESTING=OFF in the build command mentioned below

cd Fast-CDR/test
git clone https://github.com/qnx-ports/googletest
cd -

# Build Fast-CDR
QNX_PROJECT_ROOT="$(pwd)/Fast-CDR" make -C build-files/ports/Fast-CDR/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/Fast-CDR

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Add git submodules
NOTE: In case you do not want to build the test, you can skip this submodule addition part as well as set the BUILD_TESTING=OFF in the build command mentioned below

cd Fast-CDR
git submodule update --init
cd -

# Build Fast-CDR
QNX_PROJECT_ROOT="$(pwd)/Fast-CDR" make -C build-files/ports/Fast-CDR/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# How to run tests

**Note**: Below steps are for running the tests on a RPi4 target.

Move the libraries and tests to the target
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move the test binaries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/fast-cdr/* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Move fast-cdr libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libfastcdr* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

Run the tests
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
find . -maxdepth 3 -type f -executable -exec sh -c 'echo "Running $1..." >> output.txt; $1 >> output.txt 2>&1' _ {} \;
```