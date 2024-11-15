**NOTE**: QNX ports are only supported from a Linux host operating system

Please make sure you have com.qnx.qnx800.target.screen.img_codecs QNX package installed to your SDP.

Before building opencv and its tests, you might want to first build and install `muslflt`
under the same staging directory. Projects using opencv on QNX might also want to link to
`muslflt` for consistent math behavior as other platforms. Without `muslflt`, some tests
may fail and you may run into inconsistencies in results compared to other platforms.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone numpy
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/opencv.git
git clone https://github.com/qnx-ports/numpy.git && cd numpy
git submodule update --init --recursive
cd ~/qnx_workspace

# Clone muslflt
git clone https://github.com/qnx-ports/muslflt.git

# Build muslflt
make -C build-files/ports/muslflt/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install QNX_PROJECT_ROOT="$(pwd)/muslflt" -j4

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4

# Build opencv
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/opencv" make -C build-files/ports/opencv INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# Compile the port for QNX
```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
# opencv depends on numpy
git clone https://github.com/qnx-ports/numpy.git
git clone https://github.com/qnx-ports/opencv.git

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
pip install -U pip Cython wheel requests

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Clone muslflt
git clone https://github.com/qnx-ports/muslflt.git

# Build muslflt
make -C build-files/ports/muslflt/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install QNX_PROJECT_ROOT="$(pwd)/muslflt" -j4

# Build numpy first
PREFIX="/usr" QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4

# Build opencv
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/opencv" make -C build-files/ports/opencv INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# How to run tests

Create directories on the target.

```bash
mkdir -p /data/home/qnxuser/opencv/libs
mkdir -p /data/home/qnxuser/opencv/sampledata
````

Set up the test environment (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# On your development machine, clone opencv_extra
git clone https://github.com/opencv/opencv_extra.git && cd opencv_extra
git checkout 4.9.0

# Download models used by the tests
cd testdata/dnn
python3 download_models.py
rm *.tar.gz
rm *.tgz

# scp opencv_extra's testdata to /data on your target
cd ~/qnx_workspace/opencv_extra
scp -r testdata qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv

# scp opencv's sample/data/* to /data on your target
cd ~/qnx_workspace/opencv/samples/data
scp -r * qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv/sampledata

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
export OPENCV_SAMPLES_DATA_PATH=/data/home/qnxuser/opencv/sampledata

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

## Install the Python Package

```bash
# Copy the package to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/python3.11/site-packages/cv2 qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv

# Copy the numpy dependencies to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/python3.11/site-packages/numpy* qnxuser@$TARGET_HOST:/data/home/qnxuser/opencv
```

To verify the installation on the target,
```bash
# Must point to opencv libs
export OPENCV_LIBDIR=/data/home/qnxuser/opencv/libs

cd /data/home/qnxuser/opencv
python -c "import cv2; print(cv2.getBuildInformation())"
```
