# lldpd [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lldpd.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lldpd.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

# Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/lldpd.git
```

# Generate configure tool and all needed build files
```bash
cd lldpd
./autogen.sh
cd -
```

# Setup a Docker container

Pre-requisite:

* Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
* Install QNX license and SDP installation (~/.qnx and ~/qnx800 by default)

```bash
# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container
```

# Or setup Ubuntu host
```bash
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh
```

# Compile the port for QNX
```bash
cd ~/qnx_workspace
# Build lldpd
make -C build-files/ports/lldpd JLEVEL=$(nproc)
```
