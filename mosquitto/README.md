**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files

# Build the Docker image and create a container
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone mosquitto
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/mosquitto.git

# Build mosquitto
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C build-files/mosquitto install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/mosquitto.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C build-files/mosquitto install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/bin/mqtt_tests root@<target-ip-address>:/system/xbin
scp $QNX_TARGET/aarch64le/usr/local/lib/lib* root@<target-ip-address>:/system/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Required for running tests
export SNAP_NAME=mosquitto

# Change directory to the test directory
cd /system/xbin/mqtt_tests
TEST_PATH=${PWD}

# Generate ssl stuff
cd test/ssl
./gen.sh
cd $TEST_PATH

# Set permissions
chmod -R a+w $TEST_PATH/*

# Run broker test
cd test/broker
python3 ./test_qnx.py
cd $TEST_PATH

# Run client test
cd test/client
./test_qnx.sh
cd $TEST_PATH

# Run lib test
cd test/lib
python3 ./test_qnx.py
```

### Failed Test
#### QEMU: possibly due to VM internet config
- ./02-subpub-qos2-receive-maximum-1.py
- ./02-subpub-qos2-receive-maximum-2.py
- ./06-bridge-clean-session-csF-lcsF.py
- ./06-bridge-clean-session-csF-lcsN.py
- ./06-bridge-clean-session-csF-lcsT.py
- ./06-bridge-clean-session-csT-lcsF.py
- ./06-bridge-clean-session-csT-lcsN.py
- ./06-bridge-clean-session-csT-lcsT.py
- ./08-ssl-bridge.py

#### QEMU and RPI4: failed when run in batch but succeeded when run individually
- ./02-subscribe-qos1.py
