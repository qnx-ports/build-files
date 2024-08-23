**NOTE**: QNX ports are only supported from a Linux host operating system

Please make sure you have com.qnx.qnx800.target.screen.img_codecs QNX package installed to your SDP.

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

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone numpy
cd ~/qnx_workspace
git clone https://gitlab.com/qnx/ports/opencv.git
git clone https://gitlab.com/qnx/ports/numpy.git && cd numpy
git submodule update --init --recursive
cd ~/qnx_workspace

# Build numpy first
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j$(nproc)

# Build opencv
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/opencv" make -C build-files/ports/opencv install -j$(nproc)
```

# Compile the port for QNX
```bash
# Clone the repos
git clone https://gitlab.com/qnx/ports/build-files.git
# opencv depends on numpy
git clone https://gitlab.com/qnx/ports/numpy.git
git clone https://gitlab.com/qnx/ports/opencv.git

# Build numpy
cd numpy
git submodule update --init --recursive
cd -

# Install python3.11 and gfortran
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common gfortran

# Create a python virtual environment and install necessary packages
python3.11 -m venv env
source env/bin/activate
pip install -U pip Cython wheel

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build numpy first
PREFIX="/usr" QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j$(nproc)

# Build opencv
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/opencv" make -C build-files/ports/opencv install -j$(nproc)
```

# How to run tests

Create directories on the target.

```bash
mkdir -p /data/home/qnxuser/opencv/libs
````

Set up the test environment (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# On your development machine, clone opencv_extra
git clone https://github.com/opencv/opencv_extra.git && cd opencv_extra
git checkout 4.9.0

# scp opencv_extra's testdata to /data on your target
scp -r testdata qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv

# scp opencv libraries (you may first need to create the lib directory)
scp $QNX_TARGET/aarch64le/usr/local/lib/libopencv* qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv/libs

# scp opencv tests
scp -r $QNX_TARGET/aarch64le/usr/local/bin/opencv_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv
```

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
cd /data/home/qnxuser/opencv/opencv_tests
chmod +x *

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/opencv/libs
export OPENCV_TEST_DATA_PATH=/data/home/qnxuser/opencv/testdata

./opencv_perf_calib3d
./opencv_perf_core
./opencv_perf_dnn
./opencv_perf_features2d
./opencv_perf_imgcodecs
./opencv_perf_imgproc
./opencv_perf_objdetect
./opencv_perf_photo
./opencv_perf_stitching
./opencv_perf_video
./opencv_perf_videoio
./opencv_test_calib3d
./opencv_test_core
./opencv_test_dnn
./opencv_test_features2d
./opencv_test_flann
./opencv_test_highgui
./opencv_test_imgcodecs
./opencv_test_imgproc
./opencv_test_ml
./opencv_test_objdetect
./opencv_test_photo
./opencv_test_stitching
./opencv_test_video
./opencv_test_videoio
```

# Install the Python Package

```bash
# Copy the package to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/python3.11/site-packages/cv2 qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv

# ssh into the target
ssh qnxuser@$TARGET_HOST

# Install the python package
cd /data/home/qnxuser/opencv
su root -c "mv cv2 /system/lib/python3.11/site-packages"
```

To verify the installation,
```bash
# Must point to opencv libs
export OPENCV_LIBDIR=/data/home/qnxuser/opencv/libs

python -c "import cv2; print(cv2.getBuildInformation())"
```
