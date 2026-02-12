
**NOTE**: QNX ports are only supported from a Linux host operating system

dump1090 (Realtek Software Defined Radio) is a low-cost software-defined radio that uses DVB-T USB dongles based on the Realtek RTL2832U chipset. It allows computers to receive radio signals and process them in software, enabling a wide range of radio applications such as FM/AM reception.

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

# Clone dump1090
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/dump1090.git

# Build dump1090
make -C build-files/ports/dump1090 install JLEVEL=4

```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/dump1090.git


# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build dump1090
make -C build-files/ports/dump1090 install JLEVEL=4

```

# Running tests

```bash
export TARGET_HOST=<target-ip-address-or-hostname>

# Copy the dependency libraries for testing

scp $QNX_TARGET/aarch64le/usr/local/lib/librtlsdr.so*   qnxuser@$TARGET_HOST:~/lib


# Copy test binaries to target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/dump1090 qnxuser@$TARGET_HOST:~/


#copy libusb to target from your  sdp location
Note: Not available in the qnx ports and internal library
scp $QNX_TARGET/target/qnx/aarch64le/usr/lib/libusb*    qnxuser@$TARGET_HOST:~/lib


```
### On target run

```bash
chmod 755 test.sh
sh test.sh
```
