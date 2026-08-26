# openvino [![Build](https://github.com/qnx-ports/build-files/actions/workflows/openvino.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/openvino.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `4` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=4` or `-j4`.

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

# Clone the dependencies and openvino
git clone -b qnx-v25.9.23 https://github.com/qnx-ports/flatbuffers.git
git clone -b qnx-v53.0.0 https://github.com/qnx-ports/ComputeLibrary
git clone -b qnx-v2022.3.0-rc1 https://github.com/qnx-ports/oneTBB
git clone -b v1.3.1 https://github.com/madler/zlib.git
git clone -b qnx-2026.1.2 https://github.com/qnx-ports/openvino

# Build flatbuffers
QNX_PROJECT_ROOT="$(pwd)/flatbuffers" make -C build-files/ports/flatbuffers INSTALL_ROOT_linux="$(pwd)/build-files/ports/flatbuffers/host_flatc" USE_INSTALL_ROOT=true install

# Build ComputeLibrary
BUILD_EXAMPLES=OFF BUILD_TESTING=OFF BUILD_SHARED_LIBS=OFF QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C build-files/ports/ComputeLibrary install -j4

# Build oneTBB
make -C build-files/ports/oneTBB install JLEVEL=4

# Build zlib
QNX_PROJECT_ROOT="$(pwd)/zlib" make -C build-files/ports/zlib install JLEVEL=4

# Apply patches and build openvino
./build-files/ports/openvino/patch.sh
QNX_PROJECT_ROOT="$(pwd)/openvino" make -C build-files/ports/openvino install JLEVEL=16
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the dependencies and openvino
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone -b qnx-v25.9.23 https://github.com/qnx-ports/flatbuffers.git
git clone -b qnx-v53.0.0 https://github.com/qnx-ports/ComputeLibrary
git clone -b qnx-v2022.3.0-rc1 https://github.com/qnx-ports/oneTBB
git clone -b v1.3.1 https://github.com/madler/zlib.git
git clone -b qnx-2026.1.2 https://github.com/qnx-ports/openvino

# Build flatbuffers
QNX_PROJECT_ROOT="$(pwd)/flatbuffers" make -C build-files/ports/flatbuffers INSTALL_ROOT_linux="$(pwd)/build-files/ports/flatbuffers/host_flatc" USE_INSTALL_ROOT=true install

# Build ComputeLibrary
BUILD_EXAMPLES=OFF BUILD_TESTING=OFF BUILD_SHARED_LIBS=OFF QNX_PROJECT_ROOT="$(pwd)/ComputeLibrary" make -C build-files/ports/ComputeLibrary install -j4

# Build oneTBB
make -C build-files/ports/oneTBB install JLEVEL=4

# Build zlib
QNX_PROJECT_ROOT="$(pwd)/zlib" make -C build-files/ports/zlib install JLEVEL=4

# Apply patches and build openvino
./build-files/ports/openvino/patch.sh
QNX_PROJECT_ROOT="$(pwd)/openvino" make -C build-files/ports/openvino install JLEVEL=16
```

# How to run tests

**Note**: We are concerned with Unit Tests specifically. Also tests have been performed on RPi4(aarch64) and QEMU(x86_64), results at the end.

## Move the test binaries and libraries to target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp -r $QNX_TARGET/<architecture>/usr/local/lib/libtbb.so.12 qnxuser@$TARGET_HOST:~/lib
scp -r build-files/ports/openvino/nto-<architecture>-<variant>/build qnxuser@$TARGET_HOST:~/
```

## Run the tests

```bash
./ov_*_unit_tests (there are 7-8 UTs which can be run individually or simple shell loop)
```

## Results

Across both architectures, most test suites pass completely. However, there are many failures in the `ov_core_unit_tests` and `ov_cpu_unit_tests` suites for both architectures.

### Detailed Breakdown

#### AArch64 (`a64_log`)

| Test Suite                         | Total Tests Ran | Passed | Failed  | Notes                          |
| :--------------------------------- | :-------------- | :----- | :------ | :----------------------------- |
| **`ov_auto_batch_unit_tests`**     | 630             | 630    | 0       | All passed                     |
| **`ov_auto_unit_tests`**           | 736             | 736    | 0       | All passed                     |
| **`ov_core_unit_tests`**           | 12,479          | 12,195 | **277** | Identical failure count to x64 |
| **`ov_cpu_unit_tests`**            | 2,194           | 1,744  | **432** | ~19% failure rate              |
| **`ov_cpu_unit_tests_vectorized`** | 1               | 1      | 0       | All passed                     |
| **`ov_hetero_unit_tests`**         | 9               | 9      | 0       | All passed                     |
| **`ov_inference_unit_tests`**      | 148             | 148    | 0       | All passed                     |

#### x64 (`x64_log`)

| Test Suite                         | Total Tests Ran | Passed | Failed  | Notes                          |
| :--------------------------------- | :-------------- | :----- | :------ | :----------------------------- |
| **`ov_auto_batch_unit_tests`**     | 630             | 630    | 0       | All passed                     |
| **`ov_auto_unit_tests`**           | 736             | 736    | 0       | All passed                     |
| **`ov_core_unit_tests`**           | 12,479          | 12,195 | **277** | Identical failure count to a64 |
| **`ov_cpu_unit_tests`**            | 2,635           | 2,115  | **497** | 441 more tests run vs. a64     |
| **`ov_cpu_unit_tests_vectorized`** | -               | -      | -       | Runtime error                  |
| **`ov_gpu_unit_tests`**            | -               | -      | -       | No resources                   |
| **`ov_hetero_unit_tests`**         | 9               | 9      | 0       | All passed                     |
| **`ov_inference_unit_tests`**      | 148             | 148    | 0       | All passed                     |

### Recurring errors across failing test suites are:

- `ov_cpu_unit_tests`: Almost all tests crash during setup with `C++ exception: "Can't get system memory values"`, likely due to non standard memory querying by APIs (maybe fixable, currently in review).
- `ov_core_unit_tests`: The majority of failures are Frontend Manager (FEM) tests crashing or returning unexpected exception types when trying to dynamically load mock or invalid frontend extension .so libraries via dlopen.
