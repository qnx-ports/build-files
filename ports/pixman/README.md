# pixman [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pixman.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pixman.yml)

Supports QNX7.1 and QNX8.0

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container or Ubuntu host

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Obtain build tools and sources
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/mesonbuild/meson.git
git clone https://gitlab.freedesktop.org/pixman/pixman.git

#checkout to the latest stable 
cd pixman
git checkout pixman-0.44.2
cd ..

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build pixman
QNX_PROJECT_ROOT="$(pwd)/pixman" JLEVEL=4 make -C build-files/ports/pixman install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libpixman* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
Tests are available, the results are provided in `tests.result`
Currently all tests are passed on both QNX7.1 and QNX8.0.

### Running tests
Tests need to be built separately. 
1. Set the environment variable: `export BUILD_TESTS=enabled`.
2. Build pixman as usual.
3. Once built, navigate to `build-files/ports/pixman/nto-aarch64-le/build/test` and remove all directories ending `.p` to remove temporary files.
4. Copy all executables left inside `build-files/ports/pixman/nto-aarch64-le/build/test` to the target system.
5. On the target system, make sure all `libpixman` binaries are deployed and the correct `LD_LIBARAY_PATH` is set.
6. Execute test binaries one by one or using a scripts; tests will take a while on weeker machines and this is expected.