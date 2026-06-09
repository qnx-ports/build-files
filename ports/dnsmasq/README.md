# Compile the port for QNX
# dnsmasq [![Build](https://github.com/qnx-ports/build-files/actions/workflows/dnsmasq.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/dnsmasq.yml)

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

# Clone dnsmasq
git clone https://github.com/qnx-ports/dnsmasq.git
cd dnsmasq
git checkout qnx-v2.92
cd ..

# Build dnsmasq
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq clean 
# use below command for SDP8
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
# use below command for SDP7.1
# install io_sock from software center before building 
USE_IOSOCK=true QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone dnsmasq
git clone https://github.com/qnx-ports/dnsmasq.git
cd dnsmasq
git checkout qnx-v2.92
cd ..

# Build dnsmasq
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq clean 
# use below command for SDP8
QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
# use below command for SDP7.1
# install io_sock from software center before building 
USE_IOSOCK=true QNX_PROJECT_ROOT="$(pwd)/dnsmasq" make -C build-files/ports/dnsmasq install
```

# Run the tests

After building dnsmasq for your QNX target, validation is straightforward. The make process already compiles test binaries and copies test data to the CPU-specific directory (nto-<cpudir>). Deploy and run tests on your target device (RPi/x86 QNX machine).

Prerequisites:
    1. Built dnsmasq artifacts in build-files/ports/dnsmasq/nto-<cpudir>/
    2. Write permissions on target /tmp (or use TMPDIR=/fs/hd0/temp)
    3. SSH access to target device

1. Deploy to Target Device
```bash
TARGET_HOST=<target-ip-or-hostname>

# Copy entire CPU directory to target
scp -r ./build-files/ports/dnsmasq/nto-aarch64-le qnxuser@$TARGET_HOST:/home/qnxuser/guests/
```
2. SSH to Target and Setup Environment
```bash
ssh qnxuser@<TARGET_HOST>
cd /home/qnxuser/guests/nto-aarch64-le

# Set library path (adjust to your install location)
export LD_LIBRARY_PATH=/usr/local/lib:$PWD:$LD_LIBRARY_PATH
```
3. Run Validation on Target 
```bash
# Execute dnsmasq application
PORT=<port-for-application>

sudo src/dnsmasq -d -q -p $PORT -u qnxuser 
```
4. Expected Results on Target
```text
dnsmasq: started, version 2.93test4-2-g2e48dec cachesize 150 
dnsmasq: log failed: Invalid argument 
dnsmasq: compile time options: IPv6 no-GNU-getopt no-DBus no-UBus no-i18n no-IDN DHCP DHCPv6 no-Lua TFTP no-conntrack no-ipset no-nftset auth no-DNSSEC loop-detect no-inotify dumpfile 
dnsmasq: reading /etc/resolv.conf 
dnsmasq: using nameserver 192.168.122.1#53 
dnsmasq: read /etc/hosts - 4 names 
````
5. Run Validation on host 
```bash
cd build-files/ports/dnsmasq/nto-<cpudir>/
./test_dnsmasq.sh
```
6. Expected Results on Target
```text
===================================
REMOTE DNSMASQ TEST REPORT
===================================
Target Server: 192.168.122.195:5354
Test Date: Thu Apr 2 02:14:50 PM IST 2026
Total Tests: 23
Passed: 23
Failed: 0
Success Rate: 100%
````
