# GTK [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gtk.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gtk.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

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
cd ~/qnx_workspace

# Clone gtk
git clone https://github.com/qnx-ports/gtk.git

# Clone meson for building gtk
git clone https://github.com/mesonbuild/meson && cd meson
git checkout 110642dd7
cd -

# Create a staging area for the GTK4 build, for example, `/tmp/staging`
# This is required for the GTK4 port due to the sheer amount of files it installs,
# and the fact that clearing all installed files is required for a fully clean build of GTK4.
# Use INSTALL_ROOT_nto to specify a staging area
QNX_PROJECT_ROOT="$(pwd)/gtk" make INSTALL_ROOT_nto=/tmp/staging USE_INSTALL_ROOT=true -C build-files/ports/gtk JLEVEL=$(nproc) install
```

# Compile the port for QNX on Ubuntu host
```bash
# Install host build dependencies
sudo apt update
sudo apt-get install sassc libglib2.0-bin ninja-build libglib2.0-dev pkg-config

# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/gtk.git
# Clone meson for building gtk
git clone https://github.com/mesonbuild/meson && cd meson
git checkout 110642dd7
cd -

# Source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh



# --Building gtk--
# Create a staging area for the GTK4 build, for example, `/tmp/staging`
# This is required for the GTK4 port due to the sheer amount of files it installs,
# and the fact that clearing all installed files is required for a fully clean build of GTK4.
# Use INSTALL_ROOT_nto to specify a staging area

export QCONF_OVERRIDE=$PWD/build-files/resources/qconf_override/qconf_override.mk
QNX_PROJECT_ROOT="$(pwd)/gtk" make INSTALL_ROOT_nto=/tmp/staging USE_INSTALL_ROOT=true -C build-files/ports/gtk JLEVEL=$(nproc) install
```

# How to run the gtk4 demo

(note, mDNS is configured from /boot/qnx_config.txt and uses qnxpi.local by
default)
```bash
# gtk will be installed to /tmp/staging
# scp the contents to /data/home/qnxuser
TARGET_HOST=<target-ip-address-or-hostname>

scp -r /tmp/staging/aarch64le/usr/local/bin qnxuser@$TARGET_HOST:/data/home/qnxuser
scp -r /tmp/staging/aarch64le/usr/local/lib qnxuser@$TARGET_HOST:/data/home/qnxuser
scp -r /tmp/staging/aarch64le/usr/local/share qnxuser@$TARGET_HOST:/data/home/qnxuser

# ssh into your QNX target
ssh qnxuser@$TARGET_HOST

# Set environment variables
export XDG_DATA_DIRS=/data/home/qnxuser/share
export GSK_RENDERER=gl

# Run the demo
gtk4-demo
```

# How to build and run qnx examples
After building gtk4 for qnx, you can additionally build [example applications](https://github.com/qnx-ports/gtk/tree/qnx_4.8.3/qnx_examples).

```bash
# QNX_STAGE should point to where gtk was previously installed (/tmp/staging/ in this case)
cd ~/qnx_workspace
QNX_STAGE=/tmp/staging make -C $(pwd)/gtk/qnx_examples install

# executables will be installed in their respective project directories in /qnx_examples

# copy the executables to your target
# for example, gtk4_thermostat_A4
scp $(pwd)/gtk/qnx_examples/gtk4_thermostat_A4/nto-aarch64-le/gtk4_thermostat_A4 qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# copy images required by these example applications to the target
scp -r $(pwd)/gtk/qnx_examples/images qnxuser@$TARGET_HOST:/data/home/qnxuser/share/

# run the examples
gtk4_thermostat_A4
```

# Caveats
- This is only an **experimental port of GTK4** itself. Dependency libraries, such as `glib`, are not fully ported and are not guaranteed to be fully functional outside of those functionalities used by GTK4.
  - As a result, the test suite of GTK4 is also not expected to work correctly.
  - Do not depend on functionalities exposed directly via dependencies such as `glib`.
- Hardware accelerated rendering is supported with OpenGL ES 2/3 on QNX 8. However, on the Raspberry Pi 4 target, the latest `ngl` renderer is known to be broken due to an upstream bug #6498. Set `GSK_RENDERER=gl` to use the legacy renderer in this case.
- All functionalities that rely on `dbus` will not work on QNX.
