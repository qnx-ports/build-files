Setting up a workspace for ROS2 Humble for QNX:

Pre-requisite: build and install QNX ROS2 Humble from [source](https://gitlab.com/qnx/ports/build-files/-/blob/main/ports/ros2/README.md).

Preferable host OS: Ubuntu 20.04

0. Optional: use [Docker](https://gitlab.com/qnx/ports/build-files/-/blob/main/docker/README.md) to have a consistent build environment.

1. Clone the sample workspace:
```bash
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files/ports/ros2/qnx-ros2-workspace
```

2. This repository has a hello_qnx in src as an example. Add your packages inside src.


3. Run the build command:
```bash
./build.sh
```


4. On target create a new directory for your group of packages:
```bash
mkdir -p /data/home/qnxuser/opt/ros/nodes
```


5. Copy your packages over to the new location:
```bash
scp -r ./install/aarch64le/* <user_name>@<ip_address>:/data/home/qnxuser/opt/ros/nodes
```

6. Add the following commands at the end of the file /etc/.profile on your target:
```bash
cd /data/home/qnxuser/opt/ros/humble
. /data/home/qnxuser/opt/ros/humble/setup.bash
cd /data/home/qnxuser/opt/ros/nodes
. /data/home/qnxuser/opt/ros/nodes/local_setup.bash
```

7. Install required python packages on your target:
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
```

8. Run your newly installed packages.
```bash
ros2 run hello_qnx hello_qnx
[INFO] [1717543110.122714926] [hello_qnx]: Hello QNX!
```
