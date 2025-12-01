# rtl-sdr [![Build](https://github.com/qnx-ports/build-files/actions/workflows/rtl-sdr.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/rtl-sdr.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

RTL-SDR (Realtek Software Defined Radio) is a low-cost software-defined radio that uses DVB-T USB dongles based on the Realtek RTL2832U chipset. It allows computers to receive radio signals and process them in software, enabling a wide range of radio applications such as FM/AM reception.

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use the maximum number of cores to build this project.

You can optionally set up a staging area folder (e.g. /tmp/staging) for <staging-install-folder> using `USE_INSTALL_ROOT=true` and INSTALL_ROOT_nto to <staging-install-folder> in below `make` command

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

# Clone rtl-sdr
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/rtl-sdr.git

# Build rtl-sdr
make -C build-files/ports/rtl-sdr install JLEVEL=4

```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/rtl-sdr.git


# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build rtl-sdr
make -C build-files/ports/rtl-sdr install JLEVEL=4

```

# Running tests

```bash
export TARGET_HOST=<target-ip-address-or-hostname>

# Copy the dependency libraries for testing

scp $QNX_TARGET/aarch64le/usr/local/lib/librtlsdr.so*   qnxuser@$TARGET_HOST:~/lib


# Copy test binaries abd script to target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/rtl-sdr-tests qnxuser@$TARGET_HOST:~/

#copy test script and run 
scp $(pwd)/build-files/ports/rtl-sdr/test.sh qnxuser@$TARGET_HOST:~/

#copy libusb to target from your  sdp location
scp libusb*   qnxuser@10.123.3.91:~/lib


```
### On target run

```bash
chmod 755 test.sh
sh test.sh
```
