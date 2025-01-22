**Note:** QNX ports are only officially supported from a **Linux Host**. Please install WSL if using Windows.

# FreeImage 3.18.0
FreeImage information: https://freeimage.sourceforge.io/

FreeImage is an open source project aimed at developers who want to support many graphics formats such as PNG, BMP, JPEG, etc. It has a number of submodules which can be compiled or diabled at will in this system. Please follow the instructions below to iinstall via cmake.

To include FreeImage as a dependency, please use the cmake build system or pkg-config.

## Installation
1. Clone the source and QNX build-files repos into a new workspace
```bash
mkdir ~/your-wksp && cd ~/your-wksp
git clone https://github.com/qnx-ports/FreeImage.git
git clone git@github.com:qnx-ports/build-files.git
```
2. **Optional** Initialize the QNX Building Docker Container
```bash
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
cd -
```

3. Build the project. *Note:* *replace* *qnx800* *with* *your* *SDP* *installation*.
```bash
source ~/qnx800/qnxsdp-env.sh
make -C build-files/ports/FreeImage/
```
TODO: COMFIGURATION OPTIONS

## Testing
TODO
