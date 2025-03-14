**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

Presequisites to install Weston:
- Install QNX SDP 8.0 Notification FD Interfaces (com.qnx.qnx800.target.notify_fd)
- Install QNX SDP 8.0 memstream (com.qnx.qnx800.target.memstream)
- Install [glib](https://github.com/qnx-ports/build-files/tree/main/ports/glib)
- Install [pixman](https://github.com/qnx-ports/build-files/tree/main/ports/pixman)
- Install [cairo](https://github.com/qnx-ports/build-files/tree/main/ports/cairo)
- Install [wayland](https://github.com/qnx-ports/build-files/tree/main/ports/wayland)
- Install [libxkbcommon](https://github.com/qnx-ports/build-files/tree/main/ports/libxkbcommon)
- Install [xkeyboard-config](https://github.com/qnx-ports/build-files/tree/main/ports/xkeyboard-config)
- Install libdrm headers

**Note: com.qnx.qnx800.target.notify_fd and com.qnx.qnx800.target.memstream are not currently available with the QNX Everywhere license**

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/

Install meson if you decide not to use docker
```bash
sudo apt install meson
```

### Build cairo
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Obtain build tools and sources
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/mesonbuild/meson.git
git clone https://gitlab.freedesktop.org/cairo/cairo.git

# Checkout to the latest stable 
cd cairo
git checkout 1.18.2
cd ..

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Optionally use the convenience script to install all dependencies
# This script will install glib and pixman
./build-files/ports/cairo/install_all.sh

# Build cairo
QNX_PROJECT_ROOT="$(pwd)/cairo" JLEVEL=4 make -C build-files/ports/cairo install
```

### Build wayland
```bash
# Clone wayland
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/wayland.git && cd wayland

# Build config.h and wayland-version.h
# The command will fail but the files will be available in the dummy directory
CC=ntox86_64-gcc \
CXX=ntox86_64-g++ \
RANLIB=ntox86_64-ranlib \
AR=ntox86_64-ar \
meson setup dummy --cross-file=/dev/null\
    -Dlibraries=false \
    -Ddocumentation=false \
    -Ddtd_validation=false \
    --prefix=/dev/null

# Move the files to the appropriate location
cp dummy/config.h .
mv dummy/config.h src/
mv dummy/src/wayland-version.h src/
rm -rf dummy/

# Build wayland
cd ~/qnx_workspace
DIST_ROOT=$(pwd)/wayland make -C build-files/ports/wayland/ install JLEVEL=4
```

### Build libxkbcommon and xkeyboard-config
```bash
# Install dependancies
pip3 install strenum

# Clone libxkbcommon and xkeyboard-config
cd ~/qnx_workspace
git clone https://github.com/xkbcommon/libxkbcommon.git
git clone https://github.com/qnx-ports/xkeyboard-config.git

# Install xkeyboard-config

# cd to xkeyboard-config
cd xkeyboard-config

# Meson setup
meson setup build --prefix=/usr

# Meson compile
meson compile -C build/

# Meson install
DESTDIR=$QNX_TARGET meson install -C build/

# Install libxkbcommon

# Checkout xkbcommon-1.8.0
cd ~/qnx_workspace/libxkbcommon
git checkout xkbcommon-1.8.0

# Apply qnx_patches if you would like to run tests
cd ~/qnx_workspace/build-files/ports/libxkbcommon
./scripts/patch.sh ~/qnx_workspace/libxkbcommon

cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/libxkbcommon" JLEVEL=4 make -C build-files/ports/libxkbcommon install
```

### Build Weston

```bash
cd ~/qnx_workspace
# Clone libdrm (will be used to install header files)
git clone https://gitlab.freedesktop.org/mesa/drm.git

# Clone weston
git clone https://github.com/qnx-ports/weston.git
cd weston
git checkout qnx-v11.0.3
OSLIST=nto DRM_ROOT=$(pwd)/drm DIST_ROOT=$(pwd)/weston make -C build-files/ports/weston/ install JLEVEL=4
```

# Run weston examples on the target
Path where libraries are stored are crucial to running weston smoothly. If you would like to change the pathing feel free to modify config files in weston/qnx/build/nto/config.h
```bash
# Run script to tranfer libraries and executbles to the target
cd ~/qnx_workspace/build-files/ports/weston/scripts

export TARGET_HOST=<target-ip-address-or-hostname>
./transfer.sh
```
## Structure
the following assumes that all dependency packages (from SDP) **and** all components built as part of this project are installed to the same location on the host machine. This location is referred to as `$INSTALL_DIR`. Adjust process accordingly if components built from this project are installed elsewhere.

Usually, in the default QNX host machine configuration, `$INSTALL_DIR`=`$QNX_TARGET`. `$PROCESSOR` indicates the target-specific install folder (i.e. aarch64le or x86_64).

Weston:
- `$INSTALL_DIR`/etc/xdg
    - --> /etc/xdg
- `$INSTALL_DIR`/usr/share/weston
    - --> /system/share/weston
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libweston
    - --> /data/home/qnxuser/lib/libweston/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/weston
    - --> /data/home/qnxuser/lib/weston/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/libexec
    - --> /data/home/qnxuser/lib/libexec
- `$INSTALL_DIR`/`$PROCESSOR`/usr/bin/weston_tests
    - --> /data/home/qnxuser/weston_tests
- `$INSTALL_DIR`/`$PROCESSOR`/usr/bin/weston-*
    - --> /data/home/qnxuser/bin/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libweston*.so*
    - --> /data/home/qnxuser/lib/

Wayland:
- `$INSTALL_DIR`/usr/share/xkb
    - -->  /usr/share/xkb
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libwayland*.so*
    - --> /data/home/qnxuser/lib/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libepoll*
    - --> /data/home/qnxuser/lib/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libtimerfd*
    - --> /data/home/qnxuser/lib/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libmemstream*
    - --> /data/home/qnxuser/lib/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libeventfd*
    - --> /data/home/qnxuser/lib/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libxkbcommon*
    - --> /data/home/qnxuser/lib/

Others:
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libpixman*
    - --> /data/home/qnxuser/lib/
- `$INSTALL_DIR`/`$PROCESSOR`/usr/lib/libcairo*
    - --> /data/home/qnxuser/lib/

```bash
# Login as root
# Password is root
su

# Create an XDG runtime directory on the target:
mkdir -p /data/var/run/user/$(id -u ${USER})
chmod 0700 /data/var/run/user/$(id -u ${USER})

# Export environment variables
mkdir -p /data/home/qnxuser/tmp
export TMPDIR=/data/home/qnxuser/tmp
export XDG_RUNTIME_DIR=/data/var/run/user/$(id -u ${USER})
export XKB_CONFIG_ROOT=/data/home/qnxuser/xkb
export LD_LIBRARY_PATH=/data/home/qnxuser/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/data/home/qnxuser/lib/libweston:$LD_LIBRARY_PATH
export PATH=/data/home/qnxuser/bin:$PATH

# Move data directories to the right path
mv weston/ /system/share/
mv xdg/ /etc
```
```bash
# Run weston
weston --fullscreen

# Run IVI weston
weston --fullscreen --config weston-ivi.ini

# Run weston client application example
weston --fullscreen

# Open terminal inside weston and run these client examples
weston-clickdot &
weston-smoke &
```

# QNX Screen backend options

The following subset of command-line and configuration options for Weston are specific to the QNX Screen backend.

## Command-line
```bash
QNX Screen backend options:
    --fullscreen

    --no-input
            Do not provide any input devices. Used for testing input-less Weston.

    --output-count=N
            Create N QNX screen windows to emulate the same number of outputs.

    --width=W, --height=H
            Make the default size of each QNX screen window WxH pixels.

    --position-x=X, --position-y=Y
            Make the default position of each QNX screen window X,Y

    --scale=N
            Give all outputs a scale factor of N.

    --display=N
            Make the default display for each QNX screen window N.

    --egl-display=N
            Make the default EGL display (GPU) for each QNX screen window N.

    --use-pixman
            Use the pixman renderer. By default weston will try to use EGL and GLES2 for rendering.
```
## Configuration (weston.ini)
```bash
name=name
    QS1       QNX Screen backend, QNX Screen window no.1

mode=mode
    On the QNX screen backend, it just sets the WIDTHxHEIGHT of the weston window.

display=display
    The display on which this QNX Screen output window should be placed.

position=X,Y
    The position where this QNX Screen output window should be placed on the display.
```

# Run weston test on target
```bash
# Login as root
# Password is root
su

# Create an XDG runtime directory on the target:
mkdir -p /data/var/run/user/$(id -u ${USER})
chmod 0700 /data/var/run/user/$(id -u ${USER})

# Export environment variables
mkdir -p /data/home/qnxuser/tmp
export TMPDIR=/data/home/qnxuser/tmp
export XDG_RUNTIME_DIR=/data/var/run/user/$(id -u ${USER})
export XKB_CONFIG_ROOT=/data/home/qnxuser/xkb
export LD_LIBRARY_PATH=/data/home/qnxuser/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/data/home/qnxuser/lib/libweston:$LD_LIBRARY_PATH
export PATH=/data/home/qnxuser/bin:$PATH

# Run the test executables
./zuc-test
```