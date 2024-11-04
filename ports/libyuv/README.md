Note: libyuv is currently only supported for aarch64le.

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

# Clone libyuv
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/libyuv.git && cd libyuv

# Build libyuv
make -f qnx.mk -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/libyuv.git && cd libyuv

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build bash
make -f qnx.mk -j4
```

libyuv will be installed to `$QNX_TARGET/aarch64le/usr/lib/libyuv.so`.
