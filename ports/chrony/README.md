# chrony [![Build](https://github.com/qnx-ports/build-files/actions/workflows/chrony.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/chrony.yml)

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

wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp

# Build gmp
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp clean 
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4

# Clone nettle
git clone https://github.com/gnutls/nettle.git 
cd nettle
git checkout tags/nettle_3.8.1_release_20220727
cd ..

# Build nettle
QNX_PROJECT_ROOT="$(pwd)/nettle" make -C build-files/ports/nettle/  install -j4

# Clone gnutls
git clone https://github.com/qnx-ports/gnutls.git
cd gnutls/
git checkout qnx-3.6.15
./bootstrap
cd ..

# Build gnutls
QNX_PROJECT_ROOT="$(pwd)/gnutls" make -C build-files/ports/gnutls install JLEVEL=4

# Clone Chrony
git clone https://github.com/qnx-ports/chrony.git

# Build Chrony
QNX_PROJECT_ROOT="$(pwd)/chrony" make -C build-files/ports/chrony clean 
QNX_PROJECT_ROOT="$(pwd)/chrony" make -C build-files/ports/chrony install JLEVEL=4
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

wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp

# Build gmp
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp clean 
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4

# Clone nettle
git clone https://github.com/gnutls/nettle.git 
cd nettle
git checkout tags/nettle_3.8.1_release_20220727
cd ..

# Build nettle
QNX_PROJECT_ROOT="$(pwd)/nettle" make -C build-files/ports/nettle/  install -j4

# Clone gnutls
git clone https://github.com/qnx-ports/gnutls.git
cd gnutls/
git checkout qnx-3.6.15
./bootstrap
cd ..

# Build gnutls
QNX_PROJECT_ROOT="$(pwd)/gnutls" make -C build-files/ports/gnutls install JLEVEL=4

# Clone Chrony
git clone https://github.com/qnx-ports/chrony.git

# Build Chrony
QNX_PROJECT_ROOT="$(pwd)/chrony" make -C build-files/ports/chrony clean 
QNX_PROJECT_ROOT="$(pwd)/chrony" make -C build-files/ports/chrony install JLEVEL=4
```
# Test chrony on Target

```bash
export TARGET_HOST=<target-ip-address-or-hostname>
mkdir chrony
mkdir -p ~/chrony/bin
mkdir -p ~/chrony/lib
mkdir -p ~/chrony/etc

# Copy the dependency libraries for testing
scp $QNX_TARGET/x86-64/usr/local/sbin/chronyd   qnxuser@$TARGET_HOST:~/chrony/bin
scp $QNX_TARGET/x86-64/usr/local/bin/chronyc   qnxuser@$TARGET_HOST:~/chrony/bin
scp $QNX_TARGET/x86-64/usr/local/lib/libgmp.so.14   qnxuser@$TARGET_HOST:~/chrony/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libhogweed.so.6   qnxuser@$TARGET_HOST:~/chrony/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libtasn1.so.12   qnxuser@$TARGET_HOST:~/chrony/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libgnutls.so.58   qnxuser@$TARGET_HOST:~/chrony/lib
scp $QNX_TARGET/x86-64/usr/local/lib/libnettle.so.8   qnxuser@$TARGET_HOST:~/chrony/lib

Prepare configure file and copy certificates and keys into ~/chrony/etc
```
# Run chrony daemon and track

```bash
./chronyd -f <path to chrony.conf>
./chronyc tracking
./chronyc sources
```
