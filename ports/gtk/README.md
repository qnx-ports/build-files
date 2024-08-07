**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
git clone https://gitlab.com/qnx/ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Create a staging area for the GTK4 build, for example, `/tmp/staging`
# This is required for the GTK4 port due to the sheer amount of files it installs,
# and the fact that clearing all installed files is required for a fully clean build of GTK4.

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
cd ~/qnx_workspace

# Clone gtk
git clone https://gitlab.com/qnx/ports/gtk.git

# Clone meson for building gtk
git clone https://github.com/mesonbuild/meson && cd meson
git checkout 110642dd7
cd -

# Build gtk
make -C build-files/ports/gtk INSTALL_ROOT_nto=/tmp/staging USE_INSTALL_ROOT=true QNX_PROJECT_ROOT="$(pwd)/gtk" JLEVEL=$(nproc) install
```

# Compile the port for QNX on Ubuntu host
```bash
# Install host build dependencies
sudo apt update
sudo apt-get install sassc libglib2.0-bin ninja-build libglib2.0-dev pkg-config

# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
# Clone meson for building gtk
git clone https://github.com/mesonbuild/meson && cd meson
git checkout 110642dd7
cd -

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build gtk
make -C build-files/ports/gtk INSTALL_ROOT_nto=/tmp/staging USE_INSTALL_ROOT=true QNX_PROJECT_ROOT="$(pwd)/gtk" JLEVEL=$(nproc) install
```

# How to run the gtk4 demo

1. Make sure your target is booted with a display device connected and ensure the QNX Screen subsystem works.
2. Transfer all files from the correct architecture subdirectory inside the staging area to your target.
   - The default prefix used by the build scripts is `/usr/local`, but can be changed using the `PREFIX` variable.
   - You can copy the files to an arbitray prefix on target too, since GTK itself does not depend on the installation path.
3. Set the following env variables (`<prefix>` is the directory on target where all the subdirectories emitted by GTK such as `bin`, `lib` is located):
   - `XDG_DATA_DIRS=<prefix>/share`
   - `LD_LIBRARY_PATH=<prefix>/lib`
   - `GSK_RENDERER=gl` on Raspberry Pi 4 (see below for explanation)
4. Run `gtk4-demo` in the bin directory.

# Caveats
- This is only an **experimental port of GTK4** itself. Dependency libraries, such as `glib`, are not fully ported and are not guaranteed to be fully functional outside of those functionalities used by GTK4.
  - As a result, the test suite of GTK4 is also not expected to work correctly.
  - Do not depend on functionalities exposed directly via dependencies such as `glib`.
- Hardware accelerated rendering is supported with OpenGL ES 2/3 on QNX 8. However, on the Raspberry Pi 4 target, the latest `ngl` renderer is known to be broken due to an upstream bug #6498. Set `GSK_RENDERER=gl` to use the legacy renderer in this case.
- All functionalities that rely on `dbus` will not work on QNX.
