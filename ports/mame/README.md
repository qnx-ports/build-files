# MAME

**Repository:** https://github.com/qnx-ports/mame \
**Upstream:** https://github.com/mamedev/mame \
**Website:** https://www.mamedev.org/ \
**Supports:** QNX 8.0 on aarch64le and x86_64


## Build and Install

As a prerequisite, you must have a QNX SDP 8.0 installation.
```bash
mkdir qnx_workspace
cd qnx_workspace
# Grab source and build files
git clone https://github.com/qnx-ports/build-files
git clone https://github.com/qnx-ports/mame
git clone https://github.com/qnx-ports/SDL

# Optionally build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in a docker container

# Build SDL2
QNX_PROJECT_ROOT="$(pwd)/SDL" make -C build-files/ports/SDL install -j4

# Build mame
make -C build-files/ports/mame install -j4
```
