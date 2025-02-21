# pugixml

A lightweight and fast xml parser.

**Repository:** https://github.com/zeux/pugixml \
**Website:** https://pugixml.org/ \
**Supports:** QNX 8.0, 7.1 on aarch64le and x86_64

# Build
Make sure you have a QNX installation and license before beginning. You can get a [free non-commercial license here](https://www.qnx.com/products/everywhere/).
```bash
# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/zeux/pugixml
git clone https://github.com/qnx-ports/build-files

# 1a. (Optional) Start the docker build environment
cd workspace/build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# 2. Source QNX SDP 8.0 or 7.1
source ~/qnx800/qnxsdp-env.sh

# 3. Navigate here and run make/make install
cd workspace/build-files/ports/pugixml
make
make install

```

# Install and Test
TODO
```bash
```