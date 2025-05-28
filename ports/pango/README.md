# pango [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pango.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pango.yml)

Supports QNX7.1 and QNX8.0

# Dependency warning

You should compile and install its dependencies before proceeding (in order).
+ [`libthai`](https://github.com/qnx-ports/build-files/tree/main/ports/libthai)
+ [`gettext-runtime`](https://github.com/qnx-ports/build-files/tree/main/ports/gettext-runtime)
+ [`fribidi`](https://github.com/qnx-ports/build-files/tree/main/ports/fribidi)
+ [`glib`](https://github.com/qnx-ports/build-files/tree/main/ports/glib)
+ [`freetype`](https://github.com/qnx-ports/build-files/tree/main/ports/freetype)
+ [`fontconfig`](https://github.com/qnx-ports/build-files/tree/main/ports/fontconfig)
+ [`cairo`](https://github.com/qnx-ports/build-files/tree/main/ports/cairo)
+ [`harfbuzz`](https://github.com/qnx-ports/build-files/tree/main/ports/harfbuzz)

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
git clone https://gitlab.gnome.org/GNOME/pango.git

#checkout to the latest stable 
cd pango
git checkout 1.56.1 
# or version 1.54.0 for gtk support
cd ..

cd meson
git checkout 1.7.0
cd ..

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Optionally use the convenience script to install all dependencies
./build-files/ports/pango/install_all.sh

# Build pango
QNX_PROJECT_ROOT="$(pwd)/pango" JLEVEL=4 make -C build-files/ports/pango install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/bin/pango-* $TARGET_USER@$TARGET_IP_ADDRESS:~/bin
scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libpango* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/bin`, `~/lib` directories do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/bin"
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
All tests are passed.
Set environment `BUILD_TEST=true` before building pango to build tests.

### Running the tests
Copy all files in `build-files/ports/pango/nto-aarch64-le/build` to your target, and run them one by one too see the test result.
You can remove all temporary files ending `.p` to speed up the process.

Some extra resources are required for the tests, to simplify the process, just copy the everything inside `pango/tests` into the same directory where the test binaries are placed.
