# libdrm [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libdrm.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libdrm.yml)

**WARNING**: libdrm only install header files and is used as a dependancy to weston.

```bash
# Source qnx710 or qnx800 to install the header files to the desired location
source ~/qnx800/qnxsdp-env.sh 

# Create a workspace and clone libdrm
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://gitlab.freedesktop.org/mesa/drm.git

# Install libdrm headers
DIST_ROOT=$(pwd)/drm make -C build-files/ports/libdrm/ install
```