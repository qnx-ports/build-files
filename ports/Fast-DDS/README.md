# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Before building Fast-DDS and its tests, you might want to first build and install `muslflt`
under the same staging directory. Projects using Fast-DDS on QNX might also want to link to
`muslflt` for consistent math behavior as other platforms. Without `muslflt`, some tests
may fail and you may run into inconsistencies in results compared to other platforms.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.
- Setup your QNX SDP environment

- Building

```bash
# Install required build tools
sudo apt install cmake python3-pip git dos2unix automake
```

Optional: Build in Docker container
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
```

```bash
# Prerequisite: Install muslflt
# Clone muslflt
git clone https://github.com/qnx-ports/muslflt.git
# Build muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4

# Get Fast-DDS
git clone https://github.com/qnx-ports/Fast-DDS.git && cd Fast-DDS
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
JLEVEL=4 make INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install
```

- Testing

**NOTE**: Before running the tests make sure you have libsqlite3.so.1 from
com.qnx.qnx800.osr.sqlite3 installed in LD_LIBRARY_PATH on the target.

Copy host files to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Copy tests from QNX_TARGET/CPUVARDIR/usr/bin/Fast-DDS_test to the target.
scp -r $QNX_TARGET/aarch64le/usr/bin/Fast-DDS_test qnxuser@$TARGET_HOST:/data/home/qnxuser

# Copy libs from QNX_TARGET/CPUVARDIR/usr/lib to the target.
scp $QNX_TARGET/aarch64le/usr/lib/libgtest.so.1.13.0 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/lib/libgmock.so.1.13.0 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/lib/libfastrtps.so.2.10 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/lib/libfastcdr.so.1 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/lib/libtinyxml2.so.6 qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/lib/libfoonathan_memory-0.7.3.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib

# Copy files for configuring tests to the target.
scp ~/qnx_workspace/build-files/ports/Fast-DDS/test_hosts.txt qnxuser@$TARGET_HOST:/data/home/qnxuser/Fast-DDS_test
```

Both examples and unit tests will now be on the target.

To setup and run only the unit tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST
# login as root so that we can create lock files (to root writable /var/lock)
login root

# Update library path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib

# Run the tests
cd /data/home/qnxuser/Fast-DDS_test

export CERTS_PATH=$PWD/certs

# Create alias records for LocatorTests
su root -c "cat test_hosts.txt >> /data/var/etc/hosts"

# Note some tests hang and will be skipped. SystemInfoTests is fixed in 8.0.2.
TESTROOT=$PWD
for test in $(find ./unittest -type f | grep Tests | grep -E -v "(SystemInfoTests|UDPv6Tests|UDPv4Tests)") ; do
    cd $TESTROOT/$(dirname $test)
    chmod +x $TESTROOT/$test
    $TESTROOT/$test
done
cd $TESTROOT
```
