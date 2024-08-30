**NOTE**: QNX ports are only supported from a Linux host operating system

ROS2 Humble for QNX

# Compile the port for QNX in a Docker container

Currently the port is supported for QNX SDP 7.1 and 8.0.

We recommend that you use Docker to build ros2 for QNX to ensure the build environment consistency.

If python3 on the target is located at `/usr/bin/python3` instead of `/system/xbin/python3`, uncomment the following line in `build-ros2.sh`.

```code
#grep -rinl "\#\!$PYTHON3_PATH" ./opt/ros/humble | xargs -d '\n' sed -i '1 i #!/usr/bin/python3'
grep -rinl "\#\!$PYTHON3_PATH" ./opt/ros/humble | xargs -d '\n' sed -i '1 i #!/system/xbin/python3'
```

The build may fail on an unclean project. To get successive builds to succeed you may need to first remove untracked files (see `git clean`).

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/build-files.git
git clone -b qnx_v1.13.0 https://gitlab.com/qnx/ports/googletest.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Build googletest
cd ~/qnx_workspace
PREFIX="/usr" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Import ros2 packages
cd ~/qnx_workspace/build-files/ports/ros2
mkdir -p src
vcs import src < ros2.repos

# Run required scripts
./scripts/colcon-ignore.sh
./scripts/patch.sh

# Specify a specific architecture you want to build it for. Otherwise, it will build for both x86_64 and aarch64
export CPU=aarch64

# Build ros2
./scripts/build-ros2.sh
```

After the build completes, ros2_humble.tar.gz will be created at QNX_TARGET/CPUVARDIR/ros2_humble.tar.gz

## Build on host without using Docker

Don't forget to source qnxsdp-env.sh in your SDP.

```bash
# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace

# Clone repos
git clone https://gitlab.com/qnx/ports/build-files.git
git clone -b qnx_v1.13.0 https://gitlab.com/qnx/ports/googletest.git

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

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build and install googletest
PREFIX="/usr" QNX_PROJECT_ROOT="$(pwd)/googletest" make -C build-files/ports/googletest install -j4

# Import ros2 packages
cd ~/qnx_workspace/build-files/ports/ros2
mkdir -p src
vcs import src < ros2.repos

# Run scripts to ignore some packages and apply QNX patches
./scripts/colcon-ignore.sh
./scripts/patch.sh

# Set LD_PRELOAD to the host libzstd.so for x86_64 SDP 7.1 builds
export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libzstd.so

# Specify a specific architecture you want to build it for. Otherwise, it will build for both x86_64 and aarch64
export CPU=aarch64

# Build ros2
./scripts/build-ros2.sh
```

# How to run tests

Use scp to move ros2_humble.tar.gz to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)

```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp ros2_humble.tar.gz qnxuser@$TARGET_HOST:/data/home/qnxuser
```

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

cd /data/home/qnxuser
tar -xvzf ./ros2_humble.tar.gz
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
pip3 install packaging pyyaml lark -t /data/home/qnxuser/.local/lib/python3.11/site-packages/
export PYTHONPATH=$PYTHONPATH:/data/home/qnxuser/opt/ros/humble/usr/lib/python3.11/site-packages/:/data/home/qnxuser/.local/lib/python3.11/site-packages/
export COLCON_PYTHON_EXECUTABLE=/system/xbin/python3

# Start the python3 interpretor on Raspberry Pi
python3
```

### Running the Listner Talker Demo on RPI4

Run listener in a terminal:

```bash
cd /data/home/qnxuser/opt/ros/humble
. /data/home/qnxuser/opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp listener
```

Run talker in another terminal:

```bash
cd /data/home/qnxuser/opt/ros/humble
. /data/home/qnxuser/opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp talker
```

### Running the dummy robot demo on RPI4

Launch the dummy robot demo node on RPI4.
```bash
cd /data/home/qnxuser/opt/ros/humble
. /data/home/qnxuser/opt/ros/humble/setup.bash
ros2 launch dummy_robot_bringup dummy_robot_bringup.launch.py
```

Install ROS2 Humble on your Ubuntu host.

There is no QNX port for rviz2.

Follow the instructions at https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html.

Start rviz2
```bash
source <ROS2_INSTALL_FOLDER>/setup.bash
rviz2
```

Please refer to https://docs.ros.org/en/humble/Tutorials/Demos/dummy-robot-demo.html for more details about the dummy robot demo.

# How to build your own node

Please refer to the README.md inside the qnx-ros2-workspace folder.
