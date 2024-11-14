**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone mosquitto
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/mosquitto.git

# Build mosquitto
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C build-files/ports/mosquitto install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/mosquitto.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/mosquitto" make -C build-files/ports/mosquitto install -j4
```

# How to run tests

Make sure the directories exist on the target:
```bash
mkdir -p /data/home/qnxuser/mqtt/lib
```

scp libraries and tests to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp -r $QNX_TARGET/aarch64le/usr/local/bin/mqtt_tests/* qnxuser@$TARGET_HOST:/data/home/qnxuser/mqtt
scp $QNX_TARGET/aarch64le/usr/local/lib/libmosquitto* qnxuser@$TARGET_HOST:/data/home/qnxuser/mqtt/lib
```

Run tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Required for running tests
export SNAP_NAME=mosquitto

# Change directory to the test directory
cd /data/home/qnxuser/mqtt
TEST_PATH=${PWD}

# Add libs to LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib

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
