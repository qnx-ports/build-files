# glib [![Build](https://github.com/qnx-ports/build-files/actions/workflows/glib.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/glib.yml)

Supports QNX7.1 and QNX8.0

## Version notice

**!!!** Please ensure that you are not using Meson from its master branch, it is currently causing issues right now.

glib currently has 2 different building profiles and only one of them should be installed on both the target and host system.

# glib (2.84.1) for QNX

**NOTE**: currently both x86_64 and aarch64le are supported

Current these versions are tested:
+ 2.84.1 

See test reports in `tests/`. They remain the same as the other version

## Dependencies notice


To compile this library, you need the following packages installed:
+ [`zlib`](https://github.com/qnx-ports/build-files/edit/main/ports/zlib)
+ [`pcre2`](https://github.com/qnx-ports/build-files/edit/main/ports/pcre2)
+ [`libffi`](https://github.com/qnx-ports/build-files/edit/main/ports/libffi)

**NOTE**: QNX ports are only supported from a Linux host operating system. Set `INSTALL_ROOT` enviroment variable to specify which directory glib will be installed to, make sure all dependencies and glib have the same `INSTALL_ROOT` variable.

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

## Compile the port for QNX


Optional pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b 2.84.1 https://gitlab.gnome.org/GNOME/glib.git

# Optionally build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# set enviroment variables
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Build glib
QNX_PROJECT_ROOT="$(pwd)/glib" JLEVEL=4 make -C build-files/ports/glib install
```

# glib for QNX (Recommanded)

**NOTE**: currently only aarch64le is supported.

Current these versions are tested:
+ 2.82.0

See test reports in `tests/`.

## Compile Glib for SDP 7.1/8.0 on a Linux host
You'll need the patched version of glib for QNX, available at https://github.com/qnx-ports/glib . For QNX 7.0.0 use the `qnx700-$VER` branch. For QNX 7.1.0 and 8.0.0, simply use `qnx-$VER` branch.

To build, first enable your SDP, and then use the cross compile config file available inside this repo under `/resources/meson`, then use meson setup to generate build script, meson compile to do the actual compiling, and finally meson install to install it to your SDP (as dependency for other project or development), or an empty folder so you can transfer it to an actual QNX system.

Here's a detailed instruction:

``` bash
# Define some variables we will use later
export QNX_VERSION=800
export QNX_ARCH=aarch64le
# Assuming your build-files repo is at ~/workspace/build-files
cd ~/workspace
# Using QNX's fork of glib
git clone https://github.com/qnx-ports/glib.git
cd glib/
# For QNX 7.1.0+, use the generic branch
git checkout qnx-2.82.2
# Generate build script
meson setup build-qnx$QNX_VERSION --cross-file ~/workspace/build-files/resources/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/usr -Dxattr=false
meson compile -C build-qnx$QNX_VERSION
# For installing into your SDP to be used as a dependency
DESTDIR=/sdp/800/target/qnx meson install --no-rebuild -C build-qnx$QNX_VERSION
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx$QNX_VERSION
```

And build products will be available in `$TARGET_DIR`

## Compile Glib for SDP 7.0
For QNX 7.0, the general steps are the same but you'll need a special branch. Also by default images of QNX 7.0 uses `/system` as `/usr`, so there are some slight changes.

```bash
# Define some variables we will use later
export QNX_VERSION=700
export QNX_ARCH=aarch64le
# Assuming your build-files repo is at ~/workspace/build-files, we will be cloning glib parallel to it
cd ~/workspace
# Using QNX's fork of glib
git clone https://github.com/qnx-ports/glib.git
cd glib/
# For QNX 7.0.0, use a special branch for it
git checkout qnx700-2.82.2
# Generate build script. Notice the prefix here is /system
meson setup build-qnx$QNX_VERSION --cross-file ~/workspace/build-files/resources/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/system -Dxattr=false
meson compile -C build-qnx$QNX_VERSION
# For installing into your SDP to be used as a dependency
DESTDIR=/sdp/700/target/qnx meson install --no-rebuild -C build-qnx$QNX_VERSION
# For installing to image, or a clean folder to be transferred to test platform
DESTDIR=/path/to/output meson install --no-rebuild -C build-qnx$QNX_VERSION
```
