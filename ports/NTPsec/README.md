# NTPsec [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ntpsec.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ntpsec.yml)

# Compile the port for QNX

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

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone ntpsec
git clone https://github.com/qnx-ports/ntpsec.git

# Build ntpsec
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec clean
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec install

```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone ntpsec
git clone https://github.com/qnx-ports/ntpsec.git

# Build ntpsec
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec clean
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec install
```

# Test NTPsec on Target

```bash
export TARGET_HOST=<target-ip-address-or-hostname>
mkdir ntpsec
mkdir -p ~/ntpsec/bin
mkdir -p ~/ntpsec/lib
mkdir -p ~/ntpsec/etc

# Copy the dependency libraries for testing
scp $QNX_TARGET/x86-64/usr/local/sbin/ntpd   qnxuser@$TARGET_HOST:~/ntpsec/bin
scp $QNX_TARGET/x86-64/usr/local/bin/ntpq  qnxuser@$TARGET_HOST:~/ntpsec/bin
scp $QNX_TARGET/x86-64/usr/local/lib/libffi.so  qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libntpc.so   qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libntpc.so.1.1.0   qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libffi.so.6   qnxuser@$TARGET_HOST:~/ntpsec/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libntpc.so.1   qnxuser@$TARGET_HOST:~/ntpsec/lib

Prepare configure file and copy certificates and keys into ~/ntpsec/etc
```
# Run ntpd daemon and track

```bash
./ntpd -n -d -c < path to ntpsec.conf >
./ntpq 
```

