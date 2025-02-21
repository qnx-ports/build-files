# pugixml

A lightweight and fast xml parser.

**Repository:** https://github.com/zeux/pugixml \
**Website:** https://pugixml.org/ \
**Supports:** QNX 8.0, 7.1 on aarch64le and x86_64

# Build
Make sure you have a QNX installation and license before beginning. You can get a [free non-commercial license here](https://www.qnx.com/products/everywhere/).
```bash
# 0. (Optional) Install muslft
# muslflt improves floating point behaviour in QNX when converting between strings and other data types. 
# It is highly recommended to build muslflt before building pugixml, as it will correct some erroneous behaviour.
# If you have built muslflt for your target, pugixml will automatically be linked against it for this reason.
# See build-files/ports/muslft for more information.

# 1. Clone repos into a workspace
cd workspace      #Or make a new one and navigate into it
git clone https://github.com/zeux/pugixml.git
git clone https://github.com/qnx-ports/build-files.git

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

To build tests, follow the above process but additionally define PUGIXML_BUILD_TESTS=ON\
e.g.
`PUGIXML_BUILD_TESTS=ON make install`

This will ready the shared object files, test file, and data into a staging/\<cpu-arch\> directory, making for easy copying.
```bash
# 1. Copy over .so files
# Without tests
scp nto-<cpu-arch>-<le,o>/build/*.so* <username>@<ip>:~/lib/
# With tests
cd staging/<cpu-arch>
ssh <username>@<ip> "mkdir -p ~/pugixml"
scp -r * <username>@<ip>:~/pugixml/

# 2. Run tests
ssh <username>@<ip>
cd pugixml
./pugixml-check
```
