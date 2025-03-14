# cairo [![Build](https://github.com/qnx-ports/build-files/actions/workflows/cairo.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/cairo.yml)

Supports QNX7.1 and QNX8.0

## QNX Software Center (QSC) compatibility warning

It is very likely that another version of these binaries are shipped with the QNX image by QSC, hence installation of this library might introduce linking conflicts at runtime. Double check which version of it was linked when cross compiling your software and make sure the proper `LD_LIBRARY_PATH` is set for the dynamic linker to work properly.

# Dependency warning

You should compile and install its dependencies before proceeding (in order).
+ [`freetype`](https://github.com/qnx-ports/build-files/tree/main/ports/freetype)
+ [`fontconfig`](https://github.com/qnx-ports/build-files/tree/main/ports/fontconfig)
+ [`glib`](https://github.com/qnx-ports/build-files/tree/main/ports/glib)
+ [`pixman`](https://github.com/qnx-ports/build-files/tree/main/ports/pixman)

A convinience script `install_all.sh` is provided for easy installation of all required dependencies, execute it just like a regular installation and set INSTALL_ROOT and JLEVEL.
To use the convinence script, please clone the entire `build-files` repository first. 
This convinience script will call `install_all.sh` inside dependencies recursively.

## Available features
```
Surface Backends
    Image                   : YES
    Recording               : YES
    Observer                : YES
    Mime                    : YES
    Tee                     : YES
    CairoScript             : YES
    PostScript              : YES
    PDF                     : YES # Tests skipped
    SVG                     : YES # Tests skipped
Font Backends
    User                    : YES
    FreeType                : YES
    Fontconfig              : YES
Functions
    PNG functions           : YES
Features and Utilities
    cairo-script-interpreter: YES
```

# Compile the port for QNX in a Docker container or Ubuntu host

**!!!** Please checkout Meson to 1.7.0 branch because the master branch of it is causing build issues right now.

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
git clone https://gitlab.freedesktop.org/cairo/cairo.git

#checkout to the latest stable 
cd cairo
git checkout 1.18.2
cd ..

# Optionally Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Optionally use the convenience script to install all dependencies
./build-files/ports/cairo/install_all.sh

# Build cairo
QNX_PROJECT_ROOT="$(pwd)/cairo" JLEVEL=4 make -C build-files/ports/cairo install
```

# Deploy binaries via SSH
Ensure all dependencies are deployed to the target system as well.
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libcairo* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/lib` directory does not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
```

# Tests
Tests are available and it takes a long time. Please refer to this [link](https://github.com/qnx-ports/cairo-test-result) and clone it to see the results. If you want to build the tests, set `BUILD_TEST=enabled`.

All pdf-surface and svg-surface tests are skipped due to missing dependencies, but you can still render to both surface normally using cairo.

Copy all files and directories in `build-files/ports/cairo/nto-aarch64-le/build/test` to the target, make sure all binaries of cairo and its dependencies are installed as well. You can remove all temporary files or directories ending `.p` or `.o` to speed up the process.
```bash
scp -r ~/build-files/ports/cairo/nto-aarch64-le/build/test $TARGET_USER@$TARGET_IP_ADDRESS:~
```

On the target system, make sure the correct `LD_LIBRARY_PATH` is set, run the test by executing `cairo-test-suite`
```bash
# In ~/test
./cairo-test-suite
```
