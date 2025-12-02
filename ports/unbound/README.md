 Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone unbound
git clone https://github.com/qnx-ports/unbound.git
cd unbound
git checkout qnx-release-1.24.1
cd ..


# Build unbound
QNX_PROJECT_ROOT="$(pwd)/unbound" make -C build-files/ports/unbound/  install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone unbound
git clone https://github.com/qnx-ports/unbound.git
cd unbound
git checkout qnx-release-1.24.1
cd ..


# Build unbound
QNX_PROJECT_ROOT="$(pwd)/unbound" make -C build-files/ports/unbound/  install -j4
```


# Testing :

After building Unbound for your QNX target, validation is straightforward. The make process already compiles test binaries and copies test data to the CPU-specific directory (nto-<cpudir>). Deploy and run tests on your target device (RPi/x86 QNX machine).

Prerequisites:
    1. Built Unbound artifacts in build-files/ports/unbound/nto-<cpudir>/
    2. Write permissions on target /tmp (or use TMPDIR=/fs/hd0/temp)
    3. SSH access to target device

1. Deploy to Target Device
```bash
# Copy entire CPU directory to target
scp -r ./build-files/ports/unbound/nto-aarch64-le qnxuser@10.123.3.62:/home/qnxuser/guests/
```
2. SSH to Target and Setup Environment
```bash
ssh qnxuser@10.123.2.191
cd /home/qnxuser/guests/nto-aarch64-le

# Set library path (adjust to your install location)
export LD_LIBRARY_PATH=/usr/local/lib:$PWD:$LD_LIBRARY_PATH
```
3. Run Validation Tests
```bash
# Execute full test suite
sh ./unboundtest.sh
```
4. Expected Results
```text
1329XXX checks ok.
selftest successful (33 checks).
testdata/acl.rpl OK
testdata/auth_nsec3_*.rpl OK
# Note: auth_xfr.rpl may fail on QNX due to /tmp limitations (non-critical)
```