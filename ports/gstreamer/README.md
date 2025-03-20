# gdk-pixbuf [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gdk-pixbuf.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gdk-pixbuf.yml)

Supports both QNX 8.0 and QNX 7.1

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.


# Dependency warning

You should compile and install its dependencies to your QNX SDP before proceed.
Please ensure that you install `zlib` before `libpng`, otherwise you might compile `zlib` twice
+ [`zlib`](https://github.com/qnx-ports/build-files/tree/main/ports/zlib)
+ [`glib`](https://github.com/qnx-ports/build-files/tree/main/ports/glib) (glib/main is prefered)
+ [`libjpeg-turbo`](https://github.com/qnx-ports/build-files/tree/main/ports/jpeg-turbo)
+ [`libpng`](https://github.com/qnx-ports/build-files/tree/main/ports/libpng)

A convinience script `install_all.sh` is provided for easy installation of all required dependencies, execute it just like a regular installation and set INSTALL_ROOT and JLEVEL.
To use the convinence script, please clone the entire `build-files` repository first. 
This convinience script will call `install_all.sh` inside dependencies recursively.

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone gdk-pixbuf
cd ~/qnx_workspace
git clone https://gitlab.gnome.org/GNOME/gdk-pixbuf.git

# checkout to the latest stable
cd gdk-pixbuf
git checkout 2.42.12
cd ..

# Optionally use the convenience script to install all dependencies
./build-files/ports/gdk-pixbuf/install_all.sh

# Build gdk-pixbuf
QNX_PROJECT_ROOT="$(pwd)/gdk-pixbuf" JLEVEL=4 make -C build-files/ports/gdk-pixbuf install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://gitlab.gnome.org/GNOME/gdk-pixbuf.git

# checkout to the latest stable
cd gdk-pixbuf
git checkout 2.42.12
cd ..

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Optionally use the convenience script to install all dependencies
./build-files/ports/gdk-pixbuf/install_all.sh

# Build gdk-pixbuf
QNX_PROJECT_ROOT="$(pwd)/gdk-pixbuf" JLEVEL=4 make -C build-files/ports/gdk-pixbuf install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r $QNX_TARGET/aarch64le/usr/local/bin $TARGET_USER@$TARGET_IP_ADDRESS:~
scp -r $QNX_TARGET/aarch64le/usr/local/lib $TARGET_USER@$TARGET_IP_ADDRESS:~
```

# Tests
Tests are not avaliable when cross compiling.

# Update gdk-pixbuf module path
Make sure all binaries required are installed. In shell:
```bash
export GDK_PIXBUF_MODULE_FILE=/path/to/cache/file
gdk-pixbuf-query-loaders --update-cache /path/to/directory/contains/module/binaries
```
`libpixbufloader-gif.so` comes by default and will be placed in `~/lib/gdk-pixbuf-2.0/2.10.0/loaders` on your target.