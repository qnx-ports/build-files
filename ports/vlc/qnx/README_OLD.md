# VLC

**Requirements:**
Meson, autotools, libtools, gettext, autopoint, nasm, yasm installed on host. QNX SDP 8.0.


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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Install some missing dependencies required to build.
# By default, the user's password in the docker container is 'password'.
sudo apt install -y gettext autopoint nasm yasm

# Clone vlc
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/vlc.git

# Build vlc
cd vlc/qnx
JLEVEL=4 make install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

# Create a directory to store vlc
ssh $TARGET_USER@TARGET_IP_ADDRESS mkdir -p vlc

# Use tar to copy files to target while preserving symlinks
tar -C vlc/qnx/nto-aarch64-le/install -cf - * | ssh $TARGET_USER@TARGET_IP_ADDRESS tar -C vlc -xf -
````

# Tests
TBD
