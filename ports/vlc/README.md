# VLC

**Repository:** https://github.com/qnx-ports/vlc \
**Upstream:** https://github.com/videolan/vlc, https://code.videolan.org/videolan/vlc\
**Website:** https://www.videolan.org/ \
**Supports:** QNX 8.0 on aarch64le and x86_64


## Build and Install
As a prerequisite, you must have a QNX SDP 8.0 installation. Please ensure you have the following packages installed as well:
- com.qnx.qnx800.target.screen.fonts.engine

Note that VLC will only run on QNX systems which support video. Audio is not yet supported.
```bash
#1. Grab source and build files: Clone VLC and Build Files repos into a new workspace
mkdir qnx_wksp
cd qnx_wksp
git clone https://github.com/qnx-ports/build-files
git clone https://github.com/qnx-ports/vlc

#2. Set up environment: Source your SDP installation
source ~/qnx800/qnxsdp-env.sh

#3. Tools: Make sure the following tools are installed on your system.
sudo apt install -y gettext autopoint nasm yasm

#4. Compile: Run make in build-files/ports/vlc. Specify QNX_PROJECT_ROOT as the path to the cloned vlc installation.
cd build-files/ports/vlc
QNX_PROJECT_ROOT=$PWD/../../../vlc/ make install
```