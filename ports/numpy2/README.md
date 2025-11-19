# numpy [![Build](https://github.com/qnx-ports/build-files/actions/workflows/numpy.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/numpy.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

**NOTE**: This document assumes that Python3.11 is being used on the target.
          If that is incorrect, replace usages of python3.11/cp311 with whatever
          is appropriate for the version of python on the target.

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
## Create a workspace
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
```

## Build the Docker image and create a container
```bash
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh
```

**NOTE** Now you are in the Docker container

## source SDP development environment in the container
```bash
source ~/qnx800/qnxsdp-env.sh
```

## Clone Numpy
```bash
cd ~/qnx_workspace
git clone -b qnx_v2.3.4 https://github.com/qnx-ports/numpy.git && cd numpy
git submodule update --init --recursive
cd ~/qnx_workspace
```

## Build numpy
```bash
QNX_PROJECT_ROOT=`pwd`/numpy JLEVEL=4 make -C build-files/ports/numpy2
```

# Compile the port for QNX on Ubuntu host

## Clone the repos
```bash
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b qnx_v2.3.4 https://github.com/qnx-ports/numpy.git
cd numpy && git submodule update --init --recursive && cd ..
```

## Install python3.11 and gfortran
```bash
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common gfortran
```

## Create a python virtual environment and install necessary packages
```bash
python3.11 -m venv env
source env/bin/activate
pip install -U pip Cython==0.29.35 wheel
```

## source SDP development environment in the container
```bash
source ~/qnx800/qnxsdp-env.sh
```

## Build numpy
```bash
QNX_PROJECT_ROOT=`pwd`/numpy JLEVEL=4 make -C build-files/ports/numpy2
```

# Deploy numpy to target

## Install via wheel

During the build a wheel file is generated. You can copy that to the target and install it directly using `pip`.

**However whether the wheel will install cleanly depends on how it was built.**

A python wheel tries to indicate what systems it is compatible with. Anything that has a native library (ie: isn't a pure python wheel) it wants to use the 'machine' name as reported by uname. On Linux that will be something like 'x86_64' or 'aarch'. So the architecture of the machine.

However QNX is different and returns a more specific identifier for the value. For example, 'x86pc' for x86_64 QEMU or 'RaspberryPi4B' for a, well, RPI 4B.

This means that for a wheel to install cleanly, without using modifiers, it needs to be built with the exact value (in lowercase) reported by 'uname -m' when run on the QNX target.

This can be achieved by setting a PYHOST_MACHINE_<cpu> variable before running the build. The value of the variable should be a space separated list of machine names to build wheels for. It is CPU specific so that the correct architecture is used to generated the wheel.

The value does not have to be lowercase, the makefile will convert it automatically.

So for example, to build a packge for the RPI4B you could use
```
PYHOST_MACHINE_aarch64=RaspberryPi4B make
```

By default the build will always produce a wheel for target's architecutre.
Continuing the above example where one builds for the RPI4B, two wheels are
actually produced:
  numpy-2.3.4-cp311-cp311-qnx_8_0_0_aarch64.whl
  numpy-2.3.4-cp311-cp311-qnx_8_0_0_raspberrypi4b.whl

The wheel files will be located in `build-files/ports/numpy/nto-<arch>`.
```bash
$ find build-files/ports/numpy2 -name "*.whl"
build-files/ports/numpy2/nto-aarch64-le/numpy-2.3.4-cp311-cp311-qnx_8_0_0_aarch64.whl
build-files/ports/numpy2/nto-aarch64-le/numpy-2.3.4-cp311-cp311-qnx_8_0_0_raspberrypi4b.whl
build-files/ports/numpy2/nto-x86_64-o/numpy-2.3.4-cp311-cp311-qnx_8_0_0_x86_64.whl
$
```

Once you've decide on which wheel to use, copy it to the target with scp.
```bash
scp <path_to_wheel_file_on_local_host> qnxuser@<target_ip>:
```

### Install target specific wheel
If the wheel you are using is specific to the target (ie: it matches the value of `uname -m`) then you can install by simply using pip. Make sure you are using a shell on the target.
```bash
pip3 install <path_to_wheel_file_on_target>
```

### Install generic architecture wheel
If the wheel you are using is generic for the architecture, you need to force pip3 to install it. Note that this method will prevent pip from installing any of numpy's dependencies. You will need to manually do that yourself if any are required.

```bash
pip3 install <path_to_wheel_file>  --platform qnx_8_0_0_<wheel_arch> --no-deps --target ~/.local/lib/python3.11/site-packages

mkdir -p .local/bin
mv .local/lib/python3.11/site-packages/bin/* .local/bin
```

## Install directly with scp

Alternatively, you can install numpy directly by using scp to copy everything to the target. This bypasses pip and may prevent pip from properly detecting that numpy is installed when resolving dependencies. But if all you want to do is use or update numpy, this is an easy way to do it.

First install numpy into your local SDP.
```bash
QNX_PROJECT_ROOT=`pwd`/numpy JLEVEL=4 make -C build-files/ports/numpy2 install

```

Then use SCP to transfer it to the target.
For aarch64 targets:
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/lib/python3.11/site-packages/numpy qnxuser@<target_ip>:
```

For x86_64 targets:
```bash
scp -r $QNX_TARGET/x86_64/usr/local/lib/python3.11/site-packages/numpy qnxuser@<target_ip>:
```

# Tests

The unittests can be run using the standard numpy [instructions](https://numpy.org/doc/2.3/reference/testing.html#testing-guidelines)

**NOTE** You'll have to install some additional modules to run the test code.
```bash
pip3 install pytest hypothesis
```

## Failing Tests

Several tests fail due to discrepencies in parsing of floating-point values represented as a string on QNX vs. on Linux. This especially impacts Numpy's longdouble data type.
The tests expected to fail are listed below:
- test_str_roundtrip
- TestRealScalars.test_dragon4_positional_interface[longdouble]
- TestRealScalars.test_dragon4_scientific_interface[longdouble]
- TestPercentile.test_linear_interpolation[inverted_cdf-False-20-longdouble-longdouble-quantile-0.4]
- TestPercentile.test_linear_interpolation[averaged_inverted_cdf-False-27.5-longdouble-longdouble-quantile-0.4]

Several tests fail due to discrepencies between QNX's floating-point support in libm and Linux's. This causes computations on QNX to provide slightly different results. The absolute/relative difference from the expected result for each test is provided below so that you can judge if it will impact your work.
- TestLog.test_log_precision_float64[(1+1e-12j)-(5e-25+1e-12j)]
  Absolute Difference = 5.e-25
  Relative Difference = 5.e-13
- TestLog.test_log_precision_float64[(1.000000000000001+3e-08j)-(1.5602230246251546e-15+2.999999999999996e-08j)]
  Absolute Difference = 5.91079015e-18
  Relative Difference = 1.97026338e-10
- TestLog.test_log_precision_float64[(0.9999995000000417+0.0009999998333333417j)-(7.831475869017683e-18+0.001j)]
  Absolute Difference = 7.83147587e-18
  Relative Difference = 7.83147587e-15
- TestLog.test_log_precision_float64[(0.9999999999999996+2.999999999999999e-08j)-(5.9107901499372034e-18+3e-08j)]
  Absolute Difference = 5.91079015e-18
  Relative Difference = 1.97026338e-10
- TestLog.test_log_precision_float64[(0.99995000042-0.009999833j)-(-7.015159763822903e-15-0.009999999665816696j)]
  Absolute Difference = 2.07547087e-17
  Relative Difference = 2.07547094e-15
- TestLog.test_log_precision_float32[z0-wref0]
  Absolute Difference = 4.5e-12
  Relative Difference = 1.5e-06
- TestLog.test_log_precision_float32[z1-wref1]
  Absolute Difference = 1.9999999e-10
  Relative Difference = 1.e-05

