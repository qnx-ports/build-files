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

# Clone tensorflow-lite
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/tensorflow.git
# Build host flatc (used in kernel tests)
mkdir -p flatc-native-build && cd flatc-native-build
cmake ../tensorflow/tensorflow/lite/tools/cmake/native_tools/flatbuffers
cmake --build .

# Clone numpy
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/numpy.git && cd numpy
git submodule update --init --recursive
cd ~/qnx_workspace

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4

# Build tensorflow-lite
QNX_PROJECT_ROOT="$(pwd)/tensorflow" QNX_PATCH_DIR="$(pwd)/build-files/ports/tensorflow/patches" TFLITE_HOST_TOOLS_DIR="$(pwd)/flatc-native-build/flatbuffers-flatc/bin/" make -C build-files/ports/tensorflow  install JLEVEL=4
```

## Build TensorFlow Lite

```bash
# Clone the repos
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/tensorflow.git
# Build host flatc (used in kernel tests)
mkdir flatc-native-build && cd flatc-native-build
cmake ../tensorflow/tensorflow/lite/tools/cmake/native_tools/flatbuffers
cmake --build .
cd ..

# Clone numpy
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/numpy.git && cd numpy
git submodule update --init --recursive
cd ~/qnx_workspace

# Install python3.11, gfortran, and pybind11
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common gfortran pybind11

# Create a python virtual environment and install necessary packages
python3.11 -m venv env
source env/bin/activate
pip install -U pip Cython wheel

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4

# Build
QNX_PROJECT_ROOT="$(pwd)/tensorflow" QNX_PATCH_DIR="$(pwd)/build-files/ports/tensorflow/patches" TFLITE_HOST_TOOLS_DIR="$(pwd)/flatc-native-build/flatbuffers-flatc/bin/" make -C build-files/ports/tensorflow  install JLEVEL=4
```

## Run tests

Create test directories on the target.

```bash
mkdir -p /data/home/qnxuser/tflite/libs
mkdir -p /data/home/qnxuser/tflite/tests
````

scp those libraries to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).

```bash
TARGET_HOST=<target-ip-address-or-hostname>

libs=(
build-files/ports/tensorflow/nto-aarch64-le/build/libtensorflow-lite.so
build-files/ports/tensorflow/nto-aarch64-le/build/kernels/libtensorflow-lite-test-external-main.so
build-files/ports/tensorflow/nto-aarch64-le/build/kernels/libtensorflow-lite-test-base.so
build-files/ports/tensorflow/nto-aarch64-le/build/lib/libgmock.so.1.12.1
build-files/ports/tensorflow/nto-aarch64-le/build/lib/libgtest.so.1.12.1
build-files/ports/tensorflow/nto-aarch64-le/build/lib/libgtest_main.so.1.12.1
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/nsync-build/libnsync_cpp.so.1
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/re2-build/libre2.so.11
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/abseil-cpp-build/absl/*/libabsl_*.so*
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/farmhash-build/libfarmhash.so
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/fft2d-build/libfft2d_fftsg2d.so
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/fft2d-build/libfft2d_fftsg.so
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/gemmlowp-build/libeight_bit_int_gemm.so
build-files/ports/tensorflow/nto-aarch64-le/build/pthreadpool/libpthreadpool.so
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/google_benchmark-build/src/libbenchmark.so.1
build-files/ports/tensorflow/nto-aarch64-le/build/_deps/xnnpack-build/libXNNPACK.so
)
scp ${libs[@]} qnxuser@$TARGET_HOST:/data/home/qnxuser/tflite/libs
```

scp those tests to the target.

```bash
scp build-files/ports/tensorflow/nto-aarch64-le/build/kernels/*_test qnxuser@$TARGET_HOST:/data/home/qnxuser/tflite/tests
scp build-files/ports/tensorflow/qnxtests.sh qnxuser@$TARGET_HOST:/data/home/qnxuser/tflite/tests
```

**NOTE**: You need to make sure the destination folders on the target exist.

Run tests on the target.

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

cd /data/home/qnxuser/tflite/tests

# Run tests
su root -c "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/tflite/libs && ./qnxtests.sh"
```

Currently these test cases fail when `-funsafe-math-optimizations` compiler flag is set, pass when this flag is not set:

```text
SoftmaxOpTest/SoftmaxOpTest.Softmax4DInt8/0, where GetParam() = "GenericOptimized"
SoftmaxOpTest/SoftmaxOpTest.Softmax4DInt8/1, where GetParam() = "Reference"
LogSoftmaxOpTest/LogSoftmaxOpTest.LogSoftmaxInt8/0, where GetParam() = "GenericOptimized"
LogSoftmaxOpTest/LogSoftmaxOpTest.LogSoftmaxInt8/1, where GetParam() = "Reference"
QuantizedPoolingOpTest.AveragePoolActivationRelu
QuantizedPoolingOpTest.AveragePoolActivationRelu1
QuantizedPoolingOpTest.AveragePoolActivationRelu6
QuantizedUInt8PoolingOpTest.MaxPoolActivationRelu
QuantizedUInt8PoolingOpTest.MaxPoolActivationRelu1
QuantizedUInt8PoolingOpTest.MaxPoolActivationRelu6
ConstUint8MeanOpTest.Rounding
```

## Run minimal example

**NOTE** Examples may require root access to run (i.e. `su root -c "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/tflite/libs && ..."`)

In `build-files/ports/ternsorflow/common.mk`, change

```bash
cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)/tensorflow/lite/
```

to

```bash
cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)/tensorflow/lite/examples/minimal/
```

In order to build the minimal example.

You can download existing tflite models and invoke the minimal example using `minimal <tflite model>` to load the model.

You can follow the intructions in `tensorflow/lite/examples/minimal/minimal.cc` to fill input tensors and read output tensors to run inference using a model.

## Run label_image example

In `common.mk`, append this argument to `CMAKE_ARGS`, then continue with normal build process in order to build `label_image` example:

```text
-DTFLITE_ENABLE_LABEL_IMAGE=ON
```

Then follow the instructions "Download sample model and image" and "Run the sample on a desktop" in `tensorflow/tensorflow/lite/examples/label_image/README.md` to run the example.

## Install the Python Package

```bash
# scp the python package
scp -r build-files/ports/tensorflow/nto-aarch64-le/build/python_loader/tflite_runtime qnxuser@$TARGET_HOST:/data/home/qnxuser
```

Verify the installation on the target.
```bash
python3 -c "import tflite_runtime as tf; print(tf.__version__)"
```

Further instructions for building an example with tflite_runtime can be found here:

https://ai.google.dev/edge/litert/microcontrollers/python

**NOTE** for image loading and processing see OpenCV.
