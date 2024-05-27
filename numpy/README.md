# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Don't forget the source qnxsdp-env.sh in your QNX SDP.

```bash
# Clone the repos
git clone https://gitlab.com/qnx/libs/qnx-ports.git
git clone https://gitlab.com/qnx/libs/numpy.git && cd numpy
git submodule update --init --recursive
cd -

# Install python3.11 and gfortran
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common gfortran

# Create a python virtual environment and install necessary packages
python3.11 -m venv env
source env/bin/activate
pip install -U pip Cython wheel

# Build
BUILD_TESTING="ON" QNX_PROJECT_ROOT="$(pwd)/numpy" make -C qnx-ports/numpy install -j$(nproc)
```

# How to run tests

scp libraries and tests to the target.
```bash
scp -r $QNX_TARGET/aarch64le/usr/local/bin/numpy_tests root@<target-ip-address>:/
scp $QNX_TARGET/aarch64le/usr/local/lib/libg* root@<target-ip-address>:/usr/lib
```

Run tests on the target.
```bash
# ssh into the target
ssh root@<target-ip-address>

# Run unit tests
cd /numpy_tests
chmod +x *
./gmock-actions_test
```
