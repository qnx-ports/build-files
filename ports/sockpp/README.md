# sockpp for QNX

[sockpp](https://github.com/fpagliughi/sockpp) built for QNX 8.0. Port generated and verified by PortPilot.

| | |
|---|---|
| Tested | QNX SDP 8.0, x86_64, QEMU target |
| Upstream | `v1.0.0` + `patches/qnx.patch` |
| Result | **33/33 test cases pass on QNX (1/1 test programs pass on QNX)** |

**NOTE**: QNX ports are only supported from a Linux host operating system

## Create a workspace

```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/fpagliughi/sockpp sockpp
git -C sockpp checkout v1.0.0
git -C sockpp apply $(pwd)/build-files/ports/sockpp/patches/qnx.patch
git clone https://github.com/qnx-ports/Catch2 Catch2   # dependency: the official Catch2 port
```

## Build

```bash
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/Catch2" make -C build-files/ports/Catch2 install JLEVEL=$(nproc)
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/sockpp" \
  make -C build-files/ports/sockpp install JLEVEL=$(nproc)
```

This installs into the SDP, as the other ports do. To use a staging area instead, add `INSTALL_ROOT_nto=$HOME/qnx-staging USE_INSTALL_ROOT=true` to every `make` line.

The tests go to `<install root>/x86_64/usr/local/bin/sockpp_tests/`.

## Run the tests on the target

```bash
IP=<target-ip>        # QEMU: mkqnximage --getip
TESTS=$QNX_TARGET/x86_64/usr/local/bin/sockpp_tests   # or $HOME/qnx-staging/x86_64/...
ssh root@$IP "mkdir -p /data/sockpp"
scp -r $TESTS/* root@$IP:/data/sockpp/
ssh root@$IP "TIMEOUT_SCALE=3 sh /data/sockpp/qnxtests.sh"
```

Each test prints a `PASS`/`FAIL`/`TIMEOUT` line, then a summary line. Logs are written to `/data/sockpp/logs/`.

## What is QNX-specific

- **`-DCMAKE_CATCH_DISCOVER_TESTS_DISCOVERY_MODE=PRE_TEST`** (in `common.mk`): test programs only run on the QNX target
- **`-lsocket`** (in `common.mk`): socket and friends are in libsocket.so.4 on QNX, not in libc

| File | Change | Why (QNX behavior) |
|---|---|---|
| `src/inet6_address.cpp` | set the sockaddr length field on QNX too | QNX's sockaddr has sin_len/sa_len like BSD, but QNX defines neither BSD nor __APPLE__ |
| `src/inet_address.cpp` | set the sockaddr length field on QNX too | QNX's sockaddr has sin_len/sa_len like BSD, but QNX defines neither BSD nor __APPLE__ |
