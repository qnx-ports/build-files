# Qt [![Build](https://github.com/qnx-ports/build-files/actions/workflows/qt.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/qt.yml)

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

# source qnxsdp-env.sh to build for qnx710
# source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for qnx800
source ~/qnx800/qnxsdp-env.sh

# Build QT for host machine
cd ~/qnx_workspace/build-files/ports/qt/nto-aarch64-le
git clone --recurse-submodules https://github.com/qt/qt5.git --branch 6.8.1
cp -r qt5 ../nto-x86_64-o
cd ../
mkdir qthostbuild && mkdir qthost
cd qthostbuild
cmake -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DQT_BUILD_EXAMPLES=OFF \
  -DQT_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX=../qthost \
  -DQT_FEATURE_opengles2=ON \
  -DBUILD_qtopcua=OFF \
  -Wno-dev \
  ../nto-aarch64-le/qt5

cmake --build . --parallel
cmake --install .
cd ~/qnx_workspace

# Build QT
BUILD_TESTING=OFF make -C build-files/ports/qt JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Install dependancies
sudo apt-get update && sudo apt-get -y upgrade

sudo apt-get install -y \
  make \
  cmake \
  build-essential \
  libclang-dev \
  clang \
  ninja-build \
  gcc \
  git \
  bison \
  python3 \
  gperf \
  sshpass \
  pkg-config \
  libfontconfig1-dev \
  libfreetype6-dev \
  libx11-dev \
  libx11-xcb-dev \
  libxext-dev \
  libxfixes-dev \
  libxi-dev \
  libxrender-dev \
  libxcb1-dev \
  libxcb-glx0-dev \
  libxcb-keysyms1-dev \
  libxcb-image0-dev \
  libxcb-shm0-dev \
  libxcb-icccm4-dev \
  libxcb-sync-dev \
  libxcb-xfixes0-dev \
  libxcb-shape0-dev \
  libxcb-randr0-dev \
  libxcb-render-util0-dev \
  libxcb-util-dev \
  libxcb-xinerama0-dev \
  libxcb-xkb-dev \
  libxcb-cursor-dev \
  libxkbcommon-dev \
  libxkbcommon-x11-dev \
  libatspi2.0-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libtiff-dev \
  libjpeg-dev \
  libxml2-dev \
  libxslt1-dev \
  freeglut3-dev

# source qnxsdp-env.sh to build for qnx710
# source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for qnx800
source ~/qnx800/qnxsdp-env.sh

# Build QT for host machine
cd ~/qnx_workspace/build-files/ports/qt/nto-aarch64-le
git clone --recurse-submodules https://github.com/qt/qt5.git --branch 6.8.1
cp -r qt5 ../nto-x86_64-o
cd ../
mkdir qthostbuild && mkdir qthost
cd qthostbuild
cmake -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DQT_BUILD_EXAMPLES=OFF \
  -DQT_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX=../qthost \
  -DQT_FEATURE_opengles2=ON \
  -DBUILD_qtopcua=OFF \
  -Wno-dev \
  ../nto-aarch64-le/qt5

cmake --build . --parallel
cmake --install .
cd ~/qnx_workspace

# Build QT
BUILD_TESTING=OFF make -C build-files/ports/qt JLEVEL=4 install
```

# How to run example
There are 2 ways to build Qt example.

## Option 1: use qt-cmake
```bash
# Build QT example using qt-cmake

# Export path to qt-cmake
export PATH=$QNX_TARGET/aarch64le/usr/local/bin:$PATH

# cd to example source code
cd ~/qnx_workspace/build-files/ports/qt/example

# Run qt-cmake
qt-cmake -DCMAKE_PREFIX_PATH=$QNX_TARGET/aarch64le/usr/ -DCMAKE_SYSTEM_PROCESSOR=aarch64le .

# Build the example
cmake --build .

# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer particles3d example to the target
scp particles3d qnxuser@$TARGET_HOST:/data/home/qnxuser/
```
## Option 2: use qmake
```bash
# Build QT example using qmake

# Export path to qmake
export PATH=$QNX_TARGET/aarch64le/usr/local/bin:$PATH

# cd to example source code
cd ~/qnx_workspace/build-files/ports/qt/example

# Run qmake
qmake

# Build the example
make

# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer particles3d example to the target
scp particles3d qnxuser@$TARGET_HOST:/data/home/qnxuser/
```
## Finally run the example on the target
```bash
# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer the necessary QNX SDP 8.0 libraries
scp $QNX_TARGET/aarch64le/usr/lib/libzstd.so.1 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer the neccesary QT libraries and plugins to the target
scp $QNX_TARGET/aarch64le/usr/local/lib/lib* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/aarch64le/usr/local/plugins/ qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp -r $QNX_TARGET/aarch64le/usr/local/qml/ qnxuser@$TARGET_HOST:/data/home/qnxuser/
```
```bash
# ssh to the target
ssh qnxuser@$TARGET_HOST

# Export the path
export LD_LIBRARY_PATH=/data/home/qnxuser/lib/:$LD_LIBRARY_PATH
export QT_PLUGIN_PATH=/data/home/qnxuser/plugins/
export QML2_IMPORT_PATH=/data/home/qnxuser/qml/
# QNX platform options are:
# no-fullscreen
# flush-screen-context
# rootwindow
# disable-EGL_KHR_surfaceless_context
export QT_QPA_PLATFORM=qnx:rootwindow

# Run the particles3d example
cd /data/home/qnxuser
./particles3d
```

# How to run tests
```bash
# Start virtual display if you are using docker
Xvfb :99 -screen 0 1024x768x16 > /dev/null 2>&1 &
export DISPLAY=:99

# Build QT with Test ON
cd ~/qnx_workspace
BUILD_TESTING=ON make -C build-files/ports/qt JLEVEL=4 install

# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer the necessary QNX SDP 8.0 libraries
scp $QNX_TARGET/aarch64le/usr/lib/libzstd.so.1 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Transfer the neccesary QT libraries and plugins to the target
scp $QNX_TARGET/aarch64le/usr/local/lib/lib* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/aarch64le/usr/local/plugins/ qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp -r $QNX_TARGET/aarch64le/usr/local/qml/ qnxuser@$TARGET_HOST:/data/home/qnxuser/

# Run script to transfer test to target
cd ~/qnx_workspace/build-files/ports/qt

# Example use case: ./scripts/transfer_tests.sh qt3d qnxuser qnxuser $TARGET_HOST
./scripts/transfer_tests.sh <subdirectory> <target_user> <password> <TARGET_HOST>

# Transfer test execute script to the target
scp scripts/run_tests.sh qnxuser@$TARGET_HOST:/data/home/qnxuser
```
```bash
# ssh to the target
ssh qnxuser@$TARGET_HOST

# Export the path
export LD_LIBRARY_PATH=/data/home/qnxuser/lib/:$LD_LIBRARY_PATH
export QT_PLUGIN_PATH=/data/home/qnxuser/plugins/
export QML2_IMPORT_PATH=/data/home/qnxuser/qml/
export QT_QPA_PLATFORM=qnx

# Run test script
cd /data/home/qnxuser

# Some test requires temp directory.
mkdir temp
export TMPDIR=/home/data/qnxuser/temp

# Example use case: sh ./sh run_tests.sh qt3d
sh run_tests.sh <subdirectory>

# Summary of the result is stored in test_result.txt
cat qt-test/<subdirectory>/test_results.txt
```
# Troubleshooting
## Mismatched library versions

When running a Qt example on your QNX target, you might encounter symbol resolution errors due to mismatched libraries between the host and the target due to version differences. For example:

```bash
qnxuser@qnxpi:~$ ./particles3d
unknown symbol: _ZNSt3__218condition_variable15__do_timed_waitERNS_11unique_lockINS_5mutexEEENS_6chrono10time_pointINS5_12steady_clockENS5_8durationIxNS_5ratioILl1ELl1000000000EEEEEEE referenced from libQt6Core.so.6
unknown symbol: _ZNSt3__212basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE9__grow_byEmmmmmm referenced from libQt6Network.so.6
ldd:FATAL: Could not resolve all symbols
```

To solve this you can transfer your QNX host libraries to the target:
```bash
scp $QNX_TARGET/aarch64le/usr/lib/lib* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```
