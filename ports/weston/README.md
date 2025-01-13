**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

Presequisites to install Weston:
- Install glib
- Install pixman
- Install cairo
- Install QNX SDP 8.0 Wayland/Weston from QNX Software Center

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

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh
```

### Build glib

```bash
# Clone and build glib for both architecture
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/glib.git
cd glib
git checkout qnx-2.82.2

# Build it for aarch64le and x86_64 architecrure
export QNX_VERSION=800
export QNX_ARCH=aarch64le
meson setup build-qnx$QNX_VERSION --cross-file ~/qnx_workspace/build-files/resources/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/usr -Dxattr=false
meson compile -C build-qnx$QNX_VERSION
DESTDIR=/path/to/qnx$QNX_VERSION/target/qnx/${architecture} meson install --no-rebuild -C build-qnx800
```

### Build pixman

```bash
# Change the path in ~/qnx-ports/build-files/resources/meson/$QNX_ARCH/qnx$QNX_VERSION.ini to your qnx_sdp_path
# This file will be used to build pixman, glib, and cairo

# Clone and build pixman for both architecture
cd ~/qnx_workspace
git clone https://gitlab.freedesktop.org/pixman/pixman.git
cd pixman
git checkout pixman-0.43.4

# Build it for aarch64le and x86_64 architecrure
export QNX_VERSION=800
export QNX_ARCH=aarch64le
meson setup build-qnx$QNX_VERSION --cross-file ~/qnx-ports/build-files/resources/meson/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/usr -Dopenmp=disabled
meson compile -C build-qnx$QNX_VERSION
DESTDIR=/path/to/qnx$QNX_VERSION/target/qnx/${architecture} meson install --no-rebuild -C build-qnx800
```

### Build cairo

```bash
# Change the path in ~/qnx-ports/build-files/resources/meson/$QNX_ARCH/qnx$QNX_VERSION.ini to your qnx_sdp_path
# This file will be used to build pixman, glib, and cairo

# Clone and build pixman for both architecture
cd ~/qnx_workspace
git clone https://gitlab.freedesktop.org/cairo/cairo.git
cd cairo
git checkout 1.18.0

# Copy everything from resources/pkgconfig/$SDP_VERSION/$ARCH to your QNX_TARGET's usr/lib/pkgconfig folder
# Build it for aarch64le and x86_64 architecrure
export QNX_VERSION=800
export QNX_ARCH=aarch64le
meson setup build-qnx$QNX_VERSION --cross-file ~/qnx-ports/build-files/resources/meson/$QNX_ARCH/qnx$QNX_VERSION.ini -Dprefix=/usr -Dtests=disabled
meson compile -C build-qnx$QNX_VERSION
DESTDIR=/path/to/qnx$QNX_VERSION/target/qnx/${architecture} meson install --no-rebuild -C build-qnx800
```

### Build Weston

```bash
cd ~/qnx_workspace
https://github.com/qnx-ports/weston.git
cd weston
git checkout qnx-v11.0.3
OSLIST=nto make -C qnx/build install JLEVEL=4 install
```

# Run weston examples on the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Path where libraries are stored are crucial to running weston smoothly
# If you would like to change the pathing feel free to modify config files in weston/qnx/build/nto/config.h

# Transfer weston libraries to the target
scp -r ~/qnx800/target/qnx/aarch64le/usr/lib/libweston* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r ~/qnx800/target/qnx/aarch64le/usr/lib/weston qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r ~/qnx800/target/qnx/aarch64le/usr/libexec qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer weston executables to the target
scp ~/qnx800/target/qnx/aarch64le/usr/sbin/weston qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp ~/qnx800/target/qnx/aarch64le/usr/bin/weston-* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Transfer weston data to the target
scp -r ~/qnx800/target/qnx/usr/share/weston qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp -r ~/qnx800/target/qnx/etc/xdg qnxuser@$TARGET_HOST:/data/home/qnxuser

# Transfer wayland libraries to the target
scp -r ~/qnx800/target/qnx/aarch64le/usr/lib/libwayland* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer dependacy libraries to the target
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libmemstream* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libpixman* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libepoll* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libtimerfd* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libsignalfd* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libeventfd* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer xkbcommon dependancy
scp ~/qnx800/target/qnx/aarch64le/usr/lib/libxkbcommon* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r ~/qnx800/target/qnx/usr/share/xkb qnxuser@$TARGET_HOST:/data/home/qnxuser/
```
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
# Trasnfer weston test libraries to the target
scp ~/qnx800/target/qnx/aarch64le/usr/lib/test-plugin.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib/weston
scp ~/qnx800/target/qnx/aarch64le/usr/lib/test-ivi-layout.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp ~/qnx800/target/qnx/aarch64le/usr/lib/weston-test-desktop-shell.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib


# Transfer test data and executables to the target
scp -r ~/qnx_workspace/weston/tests/reference qnxuser@$TARGET_HOST:/data/home/qnxuser
scp ~/qnx800/target/qnx/aarch64le/usr/lib/weston-test-* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

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
export PATH=/data/home/qnxuser/bin:$PATH

# Run the test executables
./zuc-test
```