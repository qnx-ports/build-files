**NOTE**: QNX ports are only supported from a Linux host operating system

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

# Clone xkeyboard-config
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/xkeyboard-config.git

# cd to xkeyboard-config
cd xkeyboard-config

# Meson setup
meson setup build --prefix=/usr

# Meson compile
meson compile -C build/

# Meson install
DESTDIR=$QNX_TARGET meson install -C build/
```

# Compile the port for QNX on Ubuntu host
```bash
# Create workspace
mkdir -p ~/qnx_workspace && cd qnx_workspace

# source qnxsdp-env.sh to build for QNX 7.1
source ~/qnx710/qnxsdp-env.sh

# source qnxsdp-env.sh to build for QNX 8.0
source ~/qnx800/qnxsdp-env.sh

# Install strenum
pip3 install strenum

# Clone xkeyboard-config
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/xkeyboard-config.git

# cd to xkeyboard-config
cd xkeyboard-config

# Meson setup
meson setup build --prefix=/usr

# Meson compile
meson compile -C build/

# Meson install
DESTDIR=$QNX_TARGET meson install -C build/
```
