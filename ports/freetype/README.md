# freetype [![Build](https://github.com/qnx-ports/build-files/actions/workflows/freetype.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/freetype.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly.

### Naming clarification
freetype is sometimes called "freetype2", "freetype6" or even "freetype-2.0". For the most of the time they are the same software.

# Dependency warning

You should compile and install its dependencies before proceeding (in order).
+ [`zlib`](https://github.com/qnx-ports/build-files/tree/main/ports/zlib)
+ [`brotli`](https://github.com/qnx-ports/build-files/tree/main/ports/brotli)
+ [`bzip2`](https://github.com/qnx-ports/build-files/tree/main/ports/bzip2)
+ [`libpng`](https://github.com/qnx-ports/build-files/tree/main/ports/libpng)

Please read details at the end about loop dependency between harfbuzz and freetype2
+ [`harfbuzz`](https://github.com/qnx-ports/build-files/tree/main/ports/harfbuzz)

A convinience script `install_all.sh` is provided for easy installation of all required dependencies, execute it just like a regular installation and set INSTALL_ROOT and JLEVEL.
To use the convinence script, please clone the entire `build-files` repository first. 
This convinience script will call `install_all.sh` inside dependencies recursively.
harfbuzz is not included in the convinience script.

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
git clone -b 1.7.0 https://github.com/mesonbuild/meson.git
git clone https://gitlab.freedesktop.org/freetype/freetype.git

#checkout to the latest stable 
cd freetype
git checkout VER-2-13-3
cd ..

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Optionally use the convenience script to install all dependencies
./build-files/ports/freetype/install_all.sh

# Build freetype2
QNX_PROJECT_ROOT="$(pwd)/freetype" JLEVEL=4 make -C build-files/ports/freetype install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libfreetype* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
Tests are not available.

# Harfbuzz (optional)
Freetype supports extra auto linting features via optional harfbuzz dependency. However harfbuzz also depends on freetype (not optional), therefore in order to enable this additional feature you must compile freetype twice following the order below:
+ 1, Compile and install freetype
+ 2, Compile and install harfbuzz
+ 3, Compile and install freetype again, the build script will automatically detect harfbuzz if it was installed
