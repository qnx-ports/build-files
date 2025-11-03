# ROS2 jazzy [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ros2-jazzy.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ros2-jazzy.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

ROS2 jazzy for QNX

# Compile the port for QNX in a Docker container

Currently the port is supported for QNX SDP 7.1 and 8.0.

We recommend that you use Docker to build ros2 for QNX to ensure the build environment consistency.

CMake version of 3.22.0 is recommended.

The build may fail on an unclean project. To get successive builds to succeed you may need to first remove untracked files (see `git clean`).

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b qnx_v1.13.0 https://github.com/qnx-ports/googletest.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Get boost library if you want to include vision_opencv in your ros2 build
cd ~/qnx_workspace
git clone https://github.com/boostorg/boost.git && cd boost
git checkout boost-1.82.0
git submodule update --init --recursive

# Apply a tools patch
cd tools/build && git apply ../../../build-files/ports/boost/tools_qnx.patch
cd ~/qnx_workspace

# Apply SA_RESTART patch to asio
cd boost/libs/asio && git apply ../../../build-files/ports/boost/asio_1.82.0_qnx.patch
cd ~/qnx_workspace

# Build boost
make -C build-files/ports/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j4

# Build googletest
cd ~/qnx_workspace
make -C build-files/ports/googletest install -j4

# Import ros2 packages
cd ~/qnx_workspace/build-files/ports/ros2/ros2-jazzy
mkdir -p src
vcs import src < ros2.repos

# Import extra packages if desired
vcs import src < ros2-extra.repos

# Run required scripts
./scripts/colcon-ignore.sh
./scripts/patch.sh

# Set LD_PRELOAD to the host libzstd.so for x86_64 builds
export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libzstd.so

# Specify a specific architecture you want to build it for. Otherwise, it will build for both x86_64 and aarch64
export CPU=aarch64

# Specify the python path on the target
export QNX_PYTHON3_PATH=/system/bin/python3

# If you would like to build test
export QNX_TESTING=ON

# Build ros2
./scripts/build-ros2.sh
```

After the build completes, ros2_jazzy.tar.gz will be created at QNX_TARGET/CPUVARDIR/ros2_jazzy.tar.gz

## Build on host without using Docker

Don't forget to source qnxsdp-env.sh in your SDP.

```bash
# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Clone repos
git clone https://github.com/qnx-ports/build-files.git
git clone -b qnx_v1.13.0 https://github.com/qnx-ports/googletest.git

# Install python 3.11
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common rename

# Create a python 3.11 virtual environment
python3.11 -m venv env
source env/bin/activate

# Install required python packages
pip install -U \
  pip \
  empy \
  lark \
  Cython==0.29.35 \
  wheel \
  colcon-common-extensions \
  vcstool \
  catkin_pkg \
  argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Get boost library if you want to include vision_opencv in your ros2 build
cd ~/qnx_workspace
git clone https://github.com/boostorg/boost.git && cd boost
git checkout boost-1.82.0
git submodule update --init --recursive

# Apply a tools patch
cd tools/build && git apply ../../../build-files/ports/boost/tools_qnx.patch
cd ~/qnx_workspace

# Apply SA_RESTART patch to asio
cd boost/libs/asio && git apply ../../../build-files/ports/boost/asio_1.82.0_qnx.patch
cd ~/qnx_workspace

# Build boost
make -C build-files/ports/boost/ install QNX_PROJECT_ROOT="$(pwd)/boost" -j4

# Build and install googletest
PREFIX="/usr" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Import ros2 packages
cd ~/qnx_workspace/build-files/ports/ros2/ros2-jazzy
mkdir -p src
vcs import src < ros2.repos

# Import extra packages if desired
vcs import src < ros2-extra.repos

# Run scripts to ignore some packages and apply QNX patches
./scripts/colcon-ignore.sh
./scripts/patch.sh

# Set LD_PRELOAD to the host libzstd.so for x86_64 builds
export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libzstd.so

# Specify a specific architecture you want to build it for. Otherwise, it will build for both x86_64 and aarch64
export CPU=aarch64

# Specify the python path on the target
export QNX_PYTHON3_PATH=/system/bin/python3

# If you would like to build test
export QNX_TESTING=ON

# Build ros2
./scripts/build-ros2.sh
```

# How to run examples and tests

Use scp to move ros2_jazzy.tar.gz to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)

```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp ros2_jazzy.tar.gz qnxuser@$TARGET_HOST:/data/home/qnxuser
```

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

cd /data/home/qnxuser
tar -xvzf ./ros2_jazzy.tar.gz
```

### Prepare Target

```bash
# Update system time
ntpdate -sb 0.pool.ntp.org 1.pool.ntp.org

# Install pip and packaging
mkdir -p /data
export TMPDIR=/data
python3 -m ensurepip
# Add pip to PATH
export PATH=$PATH:/data/home/qnxuser/.local/bin
pip3 install argcomplete packaging pyyaml lark -t /data/home/qnxuser/.local/lib/python3.11/site-packages/
export PYTHONPATH=$PYTHONPATH:/data/home/qnxuser/opt/ros/jazzy/lib/python3.11/site-packages/:/data/home/qnxuser/opt/ros/jazzy/usr/lib/python3.11/site-packages/:/data/home/qnxuser/.local/lib/python3.11/site-packages/
export COLCON_PYTHON_EXECUTABLE=/system/bin/python3
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/opt/ros/jazzy/lib

# Setup Environment
. opt/ros/jazzy/setup.bash
# or use the full path to source if the command above fails
# . /data/home/qnxuser/opt/ros/jazzy/setup.bash

# List Packages
ros2 pkg list
```

### Running the Listner Talker Demo on RPI4

Run listener in a terminal:
```bash
ros2 run demo_nodes_cpp listener
```

Run talker in another terminal:

```bash
ros2 run demo_nodes_cpp talker
```

### Running the dummy robot demo on RPI4

Launch the dummy robot demo node on RPI4.
```bash
ros2 launch dummy_robot_bringup dummy_robot_bringup_launch.py
```

Install ROS2 jazzy on your Ubuntu host.

There is no QNX port for rviz2.

Follow the instructions at https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debians.html.

Start rviz2

Please refer to https://docs.ros.org/en/jazzy/Tutorials/Demos/dummy-robot-demo.html for more details about the dummy robot demo.

```bash
source <ROS2_INSTALL_FOLDER>/setup.bash
rviz2
```

### Running QNX test
Tested Packages:
- Fast-CDR
- Fast-DDS
- libstatistics_collector
- rcpputils
- rmw
- rosidl_runtime_c
- rosidl_typesupport_cpp
- rosidl_typesupport_fastrtps_cpp

**Note: Fast-DDS test are skipped in ros2 port. Instead the test results for Fast-DDS can be found [here](https://github.com/qnx-ports/build-files/blob/main/ports/Fast-DDS/fdds.test.result))**
```bash
cd /data/home/qnxuser/opt/ros/jazzy
sh qnxtest.sh
```

# How to build your own node

Please refer to the README.md inside the cloned [qnx-ros2-workspace](https://github.com/qnx-ports/qnx-ros2-workspace/tree/main) repository.
