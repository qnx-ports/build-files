**NOTE**: QNX ports are only supported from a Linux host operating system

vsomeip is currently supported only for SDP 7.1.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
WORKSPACE=${PWD}
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/vsomeip.git  -b qnx_3.4.10
# Optional: get googletest if you want to run vsomeip tests
git clone https://gitlab.com/qnx/ports/googletest.git -b qnx_v1.13.0
GTEST_ROOT=$WORKSPACE/googletest


# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
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

# Build and install boost
QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost install -j$(nproc)

# Build vsomeip
# TEST_IP_MASTER should be your QNX target's ip address while TEST_IP_SLAVE should be your Ubuntu PC. It could be vice versa, but
# the test instructions below follow the forementioned setup.
TEST_IP_MASTER="<QNX-target-ip-address>" TEST_IP_SLAVE="<Ubuntu-ip-address>" QNX_PROJECT_ROOT="$(pwd)/vsomeip" make -C build-files/ports/vsomeip install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
WORKSPACE=${PWD}
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/vsomeip.git -b qnx_3.4.10
# Optional: get googletest if you want to run vsomeip tests
git clone https://gitlab.com/qnx/ports/googletest.git -b qnx_v1.13.0
GTEST_ROOT=$WORKSPACE/googletest

# source qnxsdp-env.sh
source ~/qnx710/qnxsdp-env.sh

# Clone boost
cd ~/qnx_workspace
WORKSPACE=${PWD}
git clone https://github.com/boostorg/boost.git && cd boost
git checkout boost-1.78.0
git submodule update --init --recursive

# Apply an interprocess boost lib patch
cd libs/interprocess && git apply $WORKSPACE/build-files/ports/boost/interprocess_1.78.0_qnx_7.1.patch
cd -

# Apply a tools patch for boost
cd tools/build && git apply $WORKSPACE/build-files/ports/boost/tools_qnx.patch
cd $WORKSPACE

# Build and install boost
QNX_PROJECT_ROOT="$(pwd)/boost" make -C build-files/ports/boost install -j$(nproc)

# Build vsomeip
# TEST_IP_MASTER should be your QNX target's ip address while TEST_IP_SLAVE should be your Ubuntu PC. It could be vice versa, but
# the test instructions below follow the forementioned setup.
TEST_IP_MASTER="<QNX-target-ip-address>" TEST_IP_SLAVE="<Ubuntu-ip-address>" QNX_PROJECT_ROOT="$(pwd)/vsomeip" make -C build-files/ports/vsomeip install -j$(nproc)
```

# How to run tests
Following files are necessary for testing.

List of Files Needed for Target:
```console
${QNX_TARGET}/${CPUVARDIR}/usr/local/lib/libboost*
${QNX_TARGET}/${CPUVARDIR}/usr/local/lib/libvsomeip3*
${QNX_TARGET}/${CPUVARDIR}/usr/local/bin/vsomeip_tests
```

Move the files to the target:
```bash
scp $QNX_TARGET/$CPUVARDIR/usr/local/lib/libboost* root@<target-ip-address>:/usr/lib
scp $QNX_TARGET/$CPUVARDIR/usr/local/lib/libvsomeip3* root@<target-ip-address>:/usr/lib
scp -r $QNX_TARGET/$CPUVARDIR/usr/local/bin/vsomeip_tests root@<target-ip-address>:/usr/bin
```

ssh into the target and chmod +x the tests:
```bash
ssh root@<target-ip-address>
chmod -R +x /usr/bin/vsomeip_tests
cd /usr/bin/vsomeip_tests/test/network_tests

# Only required for 3.4.10
cp /usr/bin/vsomeip_tests/test/common/libvsomeip_utilities.so /usr/lib
```

We will use 2 devices for the tests: a QNX 7.1 target, and the host Linux PC.

We will assume that TEST_IP_SLAVE is the ip address of the host Linux PC and that
TEST_IP_MASTER is the ip address of the QNX 7.1 target.

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
./bootstrap
sudo ./b2 install
cd -

# Build vsomeip and its tests
git clone https://github.com/COVESA/vsomeip.git && cd vsomeip
git checkout 3.4.10
# Apply a patch for suppressing a stringop-overflow error in interval_set_algo.hpp in boost
git apply ~/qnx_workspace/build-files/ports/vsomeip/vsomeip_host.patch
mkdir build && cd build
cmake -DTEST_IP_SLAVE=<host-PC-ip-address> -DTEST_IP_MASTER=<target-ip-address> ../
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
sh ./local_routing_test_starter_qnx.sh
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
