# vsomeip [![Build](https://github.com/qnx-ports/build-files/actions/workflows/vsomeip.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/vsomeip.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/vsomeip.git  -b qnx_3.4.10
# Optional: get googletest if you want to run vsomeip tests
git clone https://github.com/qnx-ports/googletest.git -b qnx_v1.13.0

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# For SDP 8.0:
source ~/qnx800/qnxsdp-env.sh
# For SDP 7.1:
#source ~/qnx710/qnxsdp-env.sh

cd ~/qnx_workspace
WORKSPACE=${PWD}
export GTEST_ROOT=$WORKSPACE/googletest

# Clone boost
git clone https://github.com/boostorg/boost.git && cd boost
# For boost 1.78.0
git checkout boost-1.78.0
# For boost 1.82.0
#git checkout boost-1.82.0
git submodule update --init --recursive

# For boost 1.78.0: apply an interprocess boost lib patch
cd libs/interprocess && git apply $WORKSPACE/build-files/ports/boost/interprocess_1.78.0_qnx_7.1.patch
cd -

# For boost 1.82.0: apply an asio patch
#cd libs/asio && git apply ../../../build-files/ports/boost/asio_1.82.0_qnx.patch
#cd -

# Apply a tools patch for boost
cd tools/build && git apply $WORKSPACE/build-files/ports/boost/tools_qnx.patch
cd $WORKSPACE

# SDP 8.0: build and install boost
BOOST_CPP_VERSION_FLAG="-std=c++17" QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost install -j4
# SDP 7.1: build and install boost
#QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost install -j4

# Build vsomeip
# TEST_IP_MASTER should be your QNX target's ip address while TEST_IP_SLAVE should be your Ubuntu PC. It could be vice versa, but
# the test instructions below follow the forementioned setup.
TEST_IP_MASTER="<QNX-target-ip-address>" TEST_IP_SLAVE="<Ubuntu-ip-address>" QNX_PROJECT_ROOT="$(pwd)/vsomeip" make -C build-files/ports/vsomeip install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
WORKSPACE=${PWD}
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/vsomeip.git -b qnx_3.4.10
# Optional: get googletest if you want to run vsomeip tests
git clone https://github.com/qnx-ports/googletest.git -b qnx_v1.13.0
GTEST_ROOT=$WORKSPACE/googletest

# For SDP 8.0:
source ~/qnx800/qnxsdp-env.sh
# For SDP 7.1:
source ~/qnx710/qnxsdp-env.sh

# Clone boost
cd ~/qnx_workspace
git clone https://github.com/boostorg/boost.git && cd boost
git checkout boost-1.78.0
git submodule update --init --recursive

# Apply an interprocess boost lib patch
cd libs/interprocess && git apply $WORKSPACE/build-files/ports/boost/interprocess_1.78.0_qnx_7.1.patch
cd -

# Apply a tools patch for boost
cd tools/build && git apply $WORKSPACE/build-files/ports/boost/tools_qnx.patch
cd $WORKSPACE

# SDP 8.0: build and install boost
BOOST_CPP_VERSION_FLAG="-std=c++17" QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost install -j4
# SDP 7.1: build and install boost
#QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost install -j4

# Build vsomeip
# TEST_IP_MASTER should be your QNX target's ip address while TEST_IP_SLAVE should be your Ubuntu PC. It could be vice versa, but
# the test instructions below follow the forementioned setup.
GTEST_ROOT=$GTEST_ROOT TEST_IP_MASTER="<QNX-target-ip-address>" TEST_IP_SLAVE="<Ubuntu-ip-address>" QNX_PROJECT_ROOT="$(pwd)/vsomeip" make -C build-files/ports/vsomeip install -j4
```

# How to run tests
Following files are necessary for testing.

List of Files Needed for Target:
```console
${QNX_TARGET}/${CPUVARDIR}/usr/local/lib/libboost*
${QNX_TARGET}/${CPUVARDIR}/usr/local/lib/libvsomeip3*
${QNX_TARGET}/${CPUVARDIR}/usr/local/bin/vsomeip_tests
```

Move the files to the target (note, mDNS is configured from /boot/qnx_config.txt
and uses qnxpi.local by default):
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp $QNX_TARGET/$CPUVARDIR/usr/local/lib/libboost* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/$CPUVARDIR/usr/local/lib/libvsomeip3* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp -r $QNX_TARGET/$CPUVARDIR/usr/local/bin/vsomeip_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
```

ssh into the target and chmod +x the tests:
```bash
ssh qnxuser@$TARGET_HOST
chmod -R +x /data/home/qnxuser/bin/vsomeip_tests
cd /data/home/qnxuser/bin/vsomeip_tests/test/network_tests

cp /data/home/qnxuser/bin/vsomeip_tests/test/common/libvsomeip_utilities.so /data/home/qnxuser/lib
```

We will use 2 devices for the tests: a QNX target, and the host Linux PC.

We will assume that TEST_IP_SLAVE is the ip address of the host Linux PC and that
TEST_IP_MASTER is the ip address of the QNX target.

## Build vsomeip for your host PC

```bash
mkdir -p ~/vsomeip_host && cd ~/vsomeip_host
WORKSPACE=${PWD}
# Download googletest
git clone https://github.com/google/googletest.git && cd googletest
git checkout release-1.8.1
cd -
GTEST_ROOT=$WORKSPACE/googletest

# Install boost 1.78.0
wget https://archives.boost.io/release/1.78.0/source/boost_1_78_0.tar.gz
tar -xvzf ./boost_1_78_0.tar.gz
cd boost_1_78_0
./bootstrap.sh
sudo ./b2 install
cd -

# Build vsomeip and its tests
git clone https://github.com/COVESA/vsomeip.git && cd vsomeip
git checkout 3.4.10
# Apply a patch for suppressing a stringop-overflow error in interval_set_algo.hpp in boost
git apply ~/qnx_workspace/build-files/ports/vsomeip/vsomeip_host.patch
mkdir build && cd build
cmake -DGTEST_ROOT=$GTEST_ROOT -DTEST_IP_SLAVE=<host-PC-ip-address> -DTEST_IP_MASTER=<target-ip-address> ../
make -j 4
make build_tests -j 4
cd test/network_tests

# Update LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKSPACE/vsomeip/build:$WORKSPACE/vsomeip/build/test/common
```

## Run vsomeip tests

### Application Test

```bash
# Run on target
sh ./application_test_starter.sh
```

### Magic Cookies Test

```bash
# Run on target
sh ./magic_cookies_test_service_start.sh
# Run on host PC
./magic_cookies_test_client_start.sh
```

### Header Factory Tests

```bash
# Run on target
./header_factory_test
# Run on target
sh ./header_factory_test_send_receive_starter.sh
```

### Routing Tests

```bash
# Run on target
sh ./local_routing_test_starter.sh
```

Run a set of routing tests:
```bash
# Start the service on the target
sh ./external_local_routing_test_service_start.sh &
# Start the client on the target
sh ./local_routing_test_client_start.sh
# Start the external client on the host PC
./external_local_routing_test_client_external_start.sh # Might have to run as sudo
```

### Payload Tests

```bash
# Run on target
sh ./local_payload_test_starter.sh
```

Second part with external visible service and local client:
```bash
# Run on target
sh ./external_local_payload_test_client_local_starter.sh
```

Third part with external visible service and external client:
```bash
# Run on target
sh ./external_local_payload_test_client_external_starter.sh
# Start the external client from the host PC
./external_local_payload_test_client_external_start.sh

```

 Fourth part with external visible service and local and external client:
 ```bash
 # Start client and service with one script on target
sh ./external_local_payload_test_client_local_and_external_starter.sh
# Start the external client from an external host if asked to on host PC
./external_local_payload_test_client_external_start.sh

 ```

### Big Payload Test

Run local tests on target:
```bash
# Run on target
sh ./big_payload_test_service_local_start.sh &
# Run on target
sh ./big_payload_test_client_local_start.sh
```

### Client ID Test

Run test with different ports:
```bash
# Run on target
sh ./client_id_test_master_starter_qnx.sh client_id_test_diff_client_ids_diff_ports_master.json
# Run on host PC
./client_id_test_slave_starter.sh client_id_test_diff_client_ids_diff_ports_slave.json
```

### Offer tests

```bash
# Run on target, you need to ctrl+c to exit after the test passes
sh ./offer_test_local_starter_qnx.sh
# Run on target, you need to ctrl+c to exit after the test passes
sh ./offer_test_external_master_starter_qnx.sh
# Then run this on external host when prompted on host PC
./offer_test_external_slave_starter.sh
```

### Subscribe notify tests

```bash
# Run on target
sh ./subscribe_notify_test_master_starter_qnx.sh UDP subscribe_notify_test_diff_client_ids_diff_ports_master.json

# Run on host PC
./subscribe_notify_test_slave_starter.sh UDP subscribe_notify_test_diff_client_ids_diff_ports_slave.json
```

### Initial event tests

```bash
# Run on target
# This test is currently under an investigation because it has an issue
sh ./initial_event_test_master_starter_qnx.sh TCP initial_event_test_diff_client_ids_diff_ports_master.json
# Run on host PC
./initial_event_test_slave_starter.sh initial_event_test_diff_client_ids_diff_ports_slave.json
```


### Offer tests

```bash
# Run on target, you need to ctrl+c to exit after the test passes
./offer_test_local_starter_qnx.sh
# Run on target
# This test is currently under an investigation because it has an issue
sh ./offer_test_external_master_starter_qnx.sh
# Run on host PC
./offer_test_external_slave_starter.sh
```

### nPDU tests

nPDU tests are temporarily disabled for QNX 7.1 because of compile errors.
