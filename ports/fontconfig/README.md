# fontconfig [![Build](https://github.com/qnx-ports/build-files/actions/workflows/fontconfig.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/fontconfig.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly.

# Dependency warning

You should compile and install its dependencies before proceeding (in order).
+ [`libexpat`](https://github.com/qnx-ports/build-files/tree/main/ports/libexpat)
+ [`libiconv`](https://github.com/qnx-ports/build-files/tree/main/ports/libiconv)
+ [`freetype`](https://github.com/qnx-ports/build-files/tree/main/ports/freetype)

A convinience script `install_all.sh` is provided for easy installation of all required dependencies, execute it just like a regular installation and set INSTALL_ROOT and JLEVEL.
To use the convinence script, please clone the entire `build-files` repository first. 
This convinience script will call `install_all.sh` inside dependencies recursively.

# Compile the port for QNX in a Docker container or Ubuntu host

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Obtain build tools and sources
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/mesonbuild/meson.git
git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git

#checkout to the latest stable 
cd fontconfig
git checkout 2.16.0
cd ..

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build fontconfig
QNX_PROJECT_ROOT="$(pwd)/fontconfig" JLEVEL=4 make -C build-files/ports/fontconfig install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/fc-* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libfontconfig* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin`, `~/lib` directories do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
Tests are not available due to the lack of Meson support on QNX.