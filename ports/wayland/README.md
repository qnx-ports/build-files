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

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Clone libffi
cd ~/qnx_workspace
git clone https://github.com/libffi/libffi.git

# Checkout v3.2.1
cd libffi
git checkout v3.2.1

# Run autogen script
./autogen.sh

source ~/qnx800/qnxsdp-env.sh
./configure --host=aarch64-unknown-nto-qnx8.0.0 --target=aarch64-unknown-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/aarch64le/usr
make install -j4
./configure --host=x86_64-pc-nto-qnx8.0.0 --target=x86_64-pc-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/x86_64/usr
make install -j4


# Clone wayland
cd ~/qnx_workspace
git https://github.com/qnx-ports/wayland.git && cd wayland

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
mv dummy/config.h ../build-files/ports/wayland/nto/
mv dummy/src/wayland-version.h src/
rm -rf dummy/

# Build wayland
cd ~/qnx_workspace
DIST_ROOT=$(pwd)/wayland make -C build-files/ports/wayland/ install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Clone libffi
cd ~/qnx_workspace
git clone https://github.com/libffi/libffi.git

# Checkout v3.2.1
cd libffi
git checkout v3.2.1

sudo apt install autoconf
sudo apt install texinfo

# Run autogen script
./autogen.sh

# Build libffi on 8.0 for aarch64le and x86_64
source ~/qnx800/qnxsdp-env.sh
./configure --host=aarch64-unknown-nto-qnx8.0.0 --target=aarch64-unknown-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/aarch64le/usr
make install -j4
./configure --host=x86_64-pc-nto-qnx8.0.0 --target=x86_64-pc-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/x86_64/usr
make install -j4

# Clone wayland
cd ~/qnx_workspace
git https://github.com/qnx-ports/wayland.git && cd wayland

# Install meson
sudo apt install python3 python3-pip
pip3 install meson

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
mv dummy/config.h ../build-files/ports/wayland/nto/
mv dummy/src/wayland-version.h src/
rm -rf dummy/

# Build wayland
cd ~/qnx_workspace
DIST_ROOT=$(pwd)/wayland make -C build-files/ports/wayland/ install JLEVEL=4

# How to run tests
```bash
cd ~/qnx_workspace

# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer wayland libraries to target
scp $QNX_TARGET/aarch64le/usr/lib/libwayland-* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer wayland test to the target
scp $QNX_TARGET/aarch64le/usr/bin/test-wayland-* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Transfer test script to target
scp build-files/ports/wayland/scripts/run_tests.sh qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
```
```bash
# ssh to the target
ssh qnxuser@$TARGET_HOST

# Switch to root
# Password is root
su

# Run test script
export LD_LIBRARY_PATH=/data/home/qnxuser/lib:$LD_LIBRARY_PATH
cd /home/data/qnxuser/bin
sh run_tests.sh 
```
