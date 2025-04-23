# numpy [![Build](https://github.com/qnx-ports/build-files/actions/workflows/numpy.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/numpy.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

**NOTE**: The numpy build system first tests for compiler flag support by doing a test compilation and checking for warnings or errors. This does not fail the build and can safely be ignored.
i.e.
```
INFO: compile options: '-Inumpy/core/src/common -Inumpy/core/src -Inumpy/core -Inumpy/core/src/npymath -Inumpy/core/src/multiarray -Inumpy/core/src/umath -Inumpy/core/src/npysort -Inumpy/core/src/_simd -Iqnx800/target/qnx/usr/include -Iqnx800/target/qnx/usr/include/python3.11 -Iqnx800/target/qnx/aarch64le/usr/include -Iqnx800/target/qnx/aarch64le/usr/include/python3.11 -Iqnx800/target/qnx/usr/include/aarch64le/python3.11 -I/usr/local/qnx/env/include -I/usr/include/python3.11 -Ibuild/src.linux-x86_64-3.11/numpy/core/src/common -Ibuild/src.linux-x86_64-3.11/numpy/core/src/npymath -c'
extra options: '-march=native'
WARN: CCompilerOpt.dist_test[636] : CCompilerOpt._dist_test_spawn[770] : Command (qcc ... -march=native) failed with exit status 1 output -> 
cc1: error: unknown value 'native' for '-march'
cc1: note: valid arguments are: armv8-a armv8.1-a armv8.2-a armv8.3-a armv8.4-a armv8.5-a armv8.6-a armv8.7-a armv8.8-a armv8-r armv9-a

WARN: CCompilerOpt.cc_test_flags[1089] : testing failed
```
or...
```
INFO: CCompilerOpt.feature_test[1559] : testing feature 'FMA3' with flags ()
INFO: C compiler: qcc ...

INFO: compile options: '-Inumpy/core/src/common -Inumpy/core/src -Inumpy/core -Inumpy/core/src/npymath -Inumpy/core/src/multiarray -Inumpy/core/src/umath -Inumpy/core/src/npysort -Inumpy/core/src/_simd -Iqnx800/target/qnx/usr/include -Iqnx800/target/qnx/usr/include/python3.11 -Iqnx800/target/qnx/aarch64le/usr/include -Iqnx800/target/qnx/aarch64le/usr/include/python3.11 -Iqnx800/target/qnx/usr/include/aarch64le/python3.11 -I/usr/local/qnx/env/include -I/usr/include/python3.11 -Ibuild/src.linux-x86_64-3.11/numpy/core/src/common -Ibuild/src.linux-x86_64-3.11/numpy/core/src/npymath -c'
extra options: '-Werror'
WARN: CCompilerOpt.dist_test[636] : CCompilerOpt._dist_test_spawn[770] : Command (qcc ... numpy/numpy/distutils/checks/cpu_fma3.o -Werror) failed with exit status 1 output -> 
numpy/numpy/distutils/checks/cpu_fma3.c:14:10: fatal error: xmmintrin.h: No such file or directory
   14 | #include <xmmintrin.h>
      |          ^~~~~~~~~~~~~
compilation terminated.

WARN: CCompilerOpt.feature_test[1575] : testing failed
```

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone numpy
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/numpy.git && cd numpy
git submodule update --init --recursive
cd ~/qnx_workspace

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/numpy.git && cd numpy
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

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4
```

# Configure CPU build
Pass the following options to make to configure the CPU optimizations used when building numpy,
```
CPU_BASELINE=<arg-list>
CPU_DISPATCH=<arg-list>
```
Read the documentation at https://numpy.org/doc/stable/reference/simd/build-options.html

# How to run tests

Setup the target environment (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default)
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# scp numpy
scp -r $QNX_TARGET/aarch64le/usr/local/lib/python3.11/site-packages/numpy qnxuser@$TARGET_HOST:/data/home/qnxuser

```

```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Update system time
ntpdate -sb 0.pool.ntp.org 1.pool.ntp.org

# Install pip to install pytest
export TMPDIR=/data
python3 -m ensurepip
# Add pip to PATH
export PATH=$PATH:/system/bin:/data/home/qnxuser/.local/bin
pip3 install pytest -t /data/home/qnxuser/.local/lib/python3.11/site-packages/
pip3 install hypothesis -t /data/home/qnxuser/.local/lib/python3.11/site-packages/
pip3 install pytz -t /data/home/qnxuser/.local/lib/python3.11/site-packages/
# Add python packages to PYTHONPATH
export PYTHONPATH=$PYTHONPATH:/data/home/qnxuser/.local/lib/python3.11/site-packages/:/data/home/qnxuser/
export NPY_AVAILABLE_MEM=16GB

# Start the python3 interpretor on Raspberry Pi
python3
```

Run tests in the python3 interpretor.
```bash
# Run the following python code
import numpy

numpy.test(label='fast', verbose=2)
```

WIP all tests pass except:
```console
test_longdouble.py:43: AssertionError

ACTUAL: 1.0
E DESIRED: 1.0000000000000000001

test_scalarprint.py:276: AssertionError

ACTUAL: ' -10.1999999999999992895'
E DESIRED: ' -10.2 '

test_umath.py:2235: AssertionError

ACTUAL: 0.0
E DESIRED: inf

test_umath.py:4179: RuntimeWarning: divide by zero encountered in divide
```
