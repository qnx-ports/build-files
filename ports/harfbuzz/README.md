# harfbuzz [![Build](https://github.com/qnx-ports/build-files/actions/workflows/harfbuzz.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/harfbuzz.yml)

Supports QNX7.1 and QNX8.0

## naming clarification

In some other package managers, there might be some extra package as "harfbuzz-icu". This is not an extra package of harfbuzz, they are optional features of it. Here is a list of available features built by the script:

+ `harfbuzz-icu`
+ `harfbuzz-cairo`
+ `harfbuzz-gobject`
+ `harfbuzz-subset`

# Dependency warning

You should compile and install its dependencies before proceeding (in order).
+ [`graphite`](https://github.com/qnx-ports/build-files/tree/main/ports/graphite)
+ [`iconv`](https://github.com/qnx-ports/build-files/tree/main/ports/iconv)
+ [`gettext-runtime`](https://github.com/qnx-ports/build-files/tree/main/ports/gettext-runtime)
+ [`icu`](https://github.com/qnx-ports/build-files/tree/main/ports/icu)
+ [`glib`](https://github.com/qnx-ports/build-files/tree/main/ports/glib)
+ [`freetype2`](https://github.com/qnx-ports/build-files/tree/main/ports/freetype2)
+ [`cairo`](https://github.com/qnx-ports/build-files/tree/main/ports/cairo)

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
git clone https://github.com/mesonbuild/meson.git
git clone https://github.com/harfbuzz/harfbuzz.git

#checkout to the latest stable 
cd harfbuzz
git checkout 10.2.0
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

# Build harfbuzz
QNX_PROJECT_ROOT="$(pwd)/harfbuzz" JLEVEL=4 make -C build-files/ports/harfbuzz install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/hb-* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libharfbuzz* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin`, `~/lib` directories do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
Tests are available, but currently there are no easy ways to run them on a QNX target system. Therefore the results will be provided instead in `test_result` directory
harfbuzz provides mutliple testsuites, but not all of them are available on QNX.
+ `hb-api`: some of the unicode tests fail.
+ `hb-fuzzing`: all passed  
+ `hb-threads`: all passed  
+ `hb-shape`: not available
+ `hb-subsets`: not available