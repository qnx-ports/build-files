# nanosvg

A simple header-file based SVG parser. 

**Repository:** https://github.com/memononen/nanosvg \
**Supports:** QNX 8.0, 7.1 on aarch64le and x86_64
**WARNING** Built as a dependency of Retropie. Not yet tested in isolation.

# Build
Make sure you have a QNX installation and license before beginning. You can get a [free non-commercial license here](https://www.qnx.com/products/everywhere/).
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/memononen/nanosvg.git
git clone https://github.com/qnx-ports/build-files.git

# 1a. (Optional) Start the docker build environment
cd workspace/build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# 2. Source QNX SDP 8.0 or 7.1
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/nanosvg
make
make install
```