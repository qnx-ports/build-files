# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/opencv.git

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/opencv" make -C qnx-ports/opencv install -j$(nproc)
```

# How to run tests

Set up the test environment
```bash
# On your development machine, clone opencv_extra
git clone git@github.com:opencv/opencv_extra.git && cd opencv_extra
git checkout 4.9.0

# scp opencv_extra's testdata to / on your target
scp -r testdata root@<target-ip-address>:/

# scp opencv libraries
scp $QNX_TARGET/aarch64le/usr/local/lib/libopencv* root@<target-ip-address>:/usr/lib

# scp opencv tests
scp -r $QNX_TARGET/aarch64le/usr/local/bin/opencv_tests root@<target-ip-address>:/usr/bin
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run tests
cd /usr/bin/opencv_tests
chmod +x

export OPENCV_TEST_DATA_PATH=/testdata

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
