# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

- Setup your QNX SDP environment

- Building

```bash
# Install required build tools
sudo apt install cmake python3-pip git dos2unix automake
```

```bash
# Get Fast-DDS
git clone git@gitlab.com:qnx/libs/Fast-DDS.git && cd Fast-DDS
git checkout qnx_2.10.1

WORKSPACE=$PWD

# Get submodules and patch them
cd $WORKSPACE

# Initialize git submodules
git submodule update --init $WORKSPACE/thirdparty/asio/ $WORKSPACE/thirdparty/fastcdr $WORKSPACE/thirdparty/tinyxml2/

# Apply QNX patch to Asio.
cd $WORKSPACE/thirdparty/asio
git apply $WORKSPACE/build_qnx/qnx_patches/asio_qnx.patch

# Apply QNX patch to Fast-CDR.
cd $WORKSPACE/thirdparty/fastcdr
git apply $WORKSPACE/build_qnx/qnx_patches/fastcdr_qnx.patch

# Apply QNX patch to TinyXML2.
# TinyXML2's CMakeLists.txt has CRLF, so use unix2dos to convert the patch to CRLF.
cd $WORKSPACE/thirdparty/tinyxml2
unix2dos $WORKSPACE/build_qnx/qnx_patches/tinyxml2_qnx.patch
git apply $WORKSPACE/build_qnx/qnx_patches/tinyxml2_qnx.patch

# Get foonathan_memory_vendor
cd $WORKSPACE
git clone https://github.com/eProsima/foonathan_memory_vendor.git

# Get googletest
cd $WORKSPACE
git clone https://github.com/google/googletest.git && cd googletest
git checkout v1.13.0
git apply $WORKSPACE/build_qnx/qnx_patches/googletest_qnx.patch

# Build
cd $WORKSPACE/build_qnx
JLEVEL=4 make install
```

- Testing

Tests will be installed to QNX_TARGET/CPUVARDIR/usr/bin/Fast-DDS_test.

scp the installed libraries under QNX_TARGET/CPUVARDIR/usr/lib and QNX_TARGET/CPUVARDIR/usr/bin/Fast-DDS_test to your target and run them.
