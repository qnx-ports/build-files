Documentation for QNX ROS2 Humble https://ros2-qnx-documentation.readthedocs.io/en/humble/

# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Currently the port is supported for QNX SDP 7.1 and 8.0.

We recommend that you use Docker to build ros2 for QNX to ensure the build environment consistency.

## Use Docker to build

Don't forget to source qnxsdp-env.sh in your SDP.

```bash
# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Create a workspace
mkdir -p ~/ros2_workspace && cd ~/ros2_workspace

# Clone repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone -b qnx_v1.13.0 https://gitlab.com/qnx/libs/googletest.git

# Build the Docker image
cd  ~/ros2_workspace/qnx-ports/ros2/docker
./docker-build-qnxros2-image.sh

# Create a Docker container using the built image
./docker-create-container.sh

# Once you're in the image, set up environment variables
. ./env/bin/activate
. ./$QNX_SDP_VERSION/qnxsdp-env.sh

# Build googletest
cd ~/ros2_workspace
JLEVEL=4 PREFIX="/usr" QNX_PROJECT_ROOT="~/ros2_workspace/googletest" make -C qnx-ports/googletest install

# Import ros2 packages
cd ~/ros2_workspace/qnx-ports/ros2
mkdir -p src
vcs import src < ros2.repos

# Run required scripts
./scripts/colcon-ignore.sh
./scripts/patch.sh

# Build ros2
./scripts/build-ros2.sh
```

After the build completes, ros2_humble.tar.gz will be created at $QNX_TARGET/$CPUVARDIR/ros2_humble.tar.gz

## Build on host without using Docker

Don't forget to source qnxsdp-env.sh in your SDP.

```bash
# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Create a workspace
mkdir -p ~/ros2_workspace && cd ~/ros2_workspace

# Clone repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone -b qnx_v1.13.0 https://gitlab.com/qnx/libs/googletest.git

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
  Cython \
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

# Build and install googletest
JLEVEL=4 PREFIX="/usr" QNX_PROJECT_ROOT="~/ros2_workspace/googletest" make -C qnx-ports/googletest install

# Import ros2 packages
cd ~/ros2_workspace/qnx-ports/ros2
mkdir -p src
vcs import src < ros2.repos

# Run scripts to ignore some packages and apply QNX patches
./scripts/colcon-ignore.sh
./scripts/patch.sh

# Set LD_PRELOAD to the host libzstd.so for x86_64 SDP 7.1 builds
export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libzstd.so

# Build ros2
./scripts/build-ros2.sh
```
