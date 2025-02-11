**NOTE**: QNX ports are only supported from a Linux host operating system

xkbcommon is of no use without keyboard configuration files.
so we need to install xkeyboard config with hidut configuration

# Compile the port for QNX in a Docker container

**Pre-requisite**: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

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

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Install dependancies
sudo apt install python3 python3-pip
pip3 install meson
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
# How to run tests
```bash
# Specify target ip address
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer data files to target
cd ~/qnx_workspace/libxkbcommon/
./test/data/sync.sh
scp -r test/data qnxuser@$TARGET_HOST:~/bin

# Transfer test executables to the target
cd ~/qnx_workspace
scp build-files/ports/libxkbcommon/nto-aarch64-le/build/test-* qnxuser@$TARGET_HOST:~/bin

# Transfer script to the target
scp build-files/ports/libxkbcommon/scripts/qnxtest.sh qnxuser@$TARGET_HOST:~/bin
```
```bash
# ssh to the target
ssh qnxuser@TARGET_HOST

# Run the test
cd /data/home/qnxuser/bin
sh qnxtest.sh
```