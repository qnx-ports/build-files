**NOTE**: QNX ports are only supported from a Linux host operating system

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone mosquitto
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/mosquitto.git

# Build mosquitto
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C build-files/ports/mosquitto install -j$(nproc)
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://gitlab.com/qnx/ports/build-files.git
git clone https://gitlab.com/qnx/ports/mosquitto.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C build-files/ports/mosquitto install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/bin/mqtt_tests qnxuser@<target-ip-address>:/data/home/qnxuser/bin
scp $QNX_TARGET/aarch64le/usr/local/lib/lib* qnxuser@<target-ip-address>:/data/home/qnxuser/lib
```

Run tests on the target.
**NOTE**: You need to make sure the destination folders on the target exist. After you scped them over, you either need to use `su root -c <command>` to move files over to `/system/xbin` and `/system/lib`, or add the destination folders to `PATH` and `LD_LIBRARY_PATH` accordingly. 

```bash
# ssh into the target
ssh qnxuser@<target-ip-address>

# Required for running tests
export SNAP_NAME=mosquitto

# Change directory to the test directory
cd /data/home/qnxuser/bin/mqtt_tests
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

#### RPI4: failed when run in batch but succeeded when run individually
- ./02-subscribe-qos1.py
