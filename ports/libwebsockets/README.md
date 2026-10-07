# libwebsockets [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libwebsockets.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libwebsockets.yml)

**NOTE**: QNX ports are only supported from Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

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
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Install dependencies
# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j$(nproc)

# Build libwebsockets
git clone https://github.com/qnx-ports/libwebsockets.git
make -C build-files/ports/libwebsockets install -j$(nproc)
```

# Compile the port for QNX on Ubuntu Host

```bash
# Source qnxsdp-env.sh in
cd ~/qnx_workspace
source ~/qnx800/qnxsdp-env.sh

# Install dependencies
# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j$(nproc)

# Build libwebsockets
git clone https://github.com/qnx-ports/libwebsockets.git
make -C build-files/ports/libwebsockets install -j$(nproc)
```

# How to Run Tests and Applications

**NOTE**: Tests are performed on [RPi4 target image available via QNX-E](https://www.qnx.com/developers/docs/qnxeverywhere/com.qnx.doc.target_images/topic/qsti/intro.html)

Move the libraries and tests to the target

```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/libwebsockets* qnxuser@$TARGET_HOST:~/lib

# Move test binaries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/libwebsockets* qnxuser@$TARGET_HOST:~/bin

# Move share binaries to the target for web based test
scp -r $QNX_TARGET/aarch64le/usr/local/share/libwebsockets-test-server qnxuser@$TARGET_HOST:~/share
```

## Run the Test Server
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib
./libwebsockets-test-server
```
**Expected/sample output:**
```
./libwebsockets-test-server 
[2026/10/07 05:37:51:0374] N: libwebsockets test server - license MIT 
[2026/10/07 05:37:51:0378] N: (C) Copyright 2010-2018 Andy Green <andy@warmcat.com> 
Using resource path "/data/share/libwebsockets-test-server" 
[2026/10/07 05:37:51:0379] N: lws_create_context: LWS: 4.5.0-v4.5.0, NET CLI SRV H1 H2 WS SS-JSON-POL ConMon IPv6-absent 
[2026/10/07 05:37:51:0389] N: [vh|2|default||7681]: lws_socket_bind: source ads 0.0.0.0 
[2026/10/07 05:38:39:1677] N: Created new mi 3fdb56cf40 '' 
[2026/10/07 05:39:04:0461] N: Created new mi 3fdb56e8c0 '' 
```

## Run the Test Client
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser/lib
./libwebsockets-test-client 0.0.0.0
```
**Expected/sample output:**
```
# ./libwebsockets-test-client 0.0.0.0 
[2026/10/07 05:38:39:1536] N: libwebsockets test client - license MIT 
[2026/10/07 05:38:39:1539] N: (C) Copyright 2010-2018 Andy Green <andy@warmcat.com> 
[2026/10/07 05:38:39:1540] N:  SSL disabled 
[2026/10/07 05:38:39:1541] N:  Cert must validate correctly (use -s to allow selfsigned) 
[2026/10/07 05:38:39:1541] N:  Requiring peer cert hostname matches 
[2026/10/07 05:38:39:1542] N: lws_create_context: LWS: 4.5.0-v4.5.0, NET CLI SRV H1 H2 WS SS-JSON-POL ConMon IPv6-absent 
[2026/10/07 05:38:39:1653] N: using  mode (ws) 
[2026/10/07 05:38:39:1654] N: dumb: connecting 
[2026/10/07 05:38:39:1658] N: mirror: connecting 
[2026/10/07 05:38:39:1678] N: mirror: LWS_CALLBACK_CLIENT_ESTABLISHED 
[2026/10/07 05:38:39:1679] N: opened mirror connection with 24878 lifetime 
[2026/10/07 05:38:39:1690] N: lws_http_client_http_response 101 
[2026/10/07 05:39:04:0450] N: closing mirror session 
[2026/10/07 05:39:04:0452] N: mirror: LWS_CALLBACK_CLOSED mirror_lifetime=0, rxb 0, rx_count 0 
[2026/10/07 05:39:04:0453] N: mirror: connecting 
[2026/10/07 05:39:04:0461] N: mirror: LWS_CALLBACK_CLIENT_ESTABLISHED 
[2026/10/07 05:39:04:0462] N: opened mirror connection with 55194 lifetime 
```
## Web Access Note
After starting the server, the test page should be accessible at:
 
http://$TARGET_HOST:7681/

## Note

For the current version, the web-based test code requires the server to fetch data from the `share` directory. The resource path is hardcoded during the build process.

To ensure the web-based tests work correctly, either:

- Replicate the host directory structure for the `share` directory on the target system, or
- Modify `CMAKE_INSTALL_PREFIX` in `common.mk` to match the target directory structure used for testing.
