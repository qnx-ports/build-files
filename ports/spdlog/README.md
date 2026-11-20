# spdlog for QNX

[spdlog](https://github.com/gabime/spdlog) built for QNX 8.0. Port generated and verified by PortPilot.

| | |
|---|---|
| Tested | QNX SDP 8.0, x86_64, QEMU target |
| Upstream | `v1.17.0` + `patches/qnx.patch` |
| Result | **180/180 test cases pass on QNX (1/1 test programs pass on QNX)** |

**NOTE**: QNX ports are only supported from a Linux host operating system

## Create a workspace

```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/gabime/spdlog spdlog
git -C spdlog checkout v1.17.0
git -C spdlog apply $(pwd)/build-files/ports/spdlog/patches/qnx.patch
```

## Build

```bash
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/spdlog" \
  make -C build-files/ports/spdlog install JLEVEL=$(nproc)
```

This installs into the SDP, as the other ports do. To use a staging area instead, add `INSTALL_ROOT_nto=$HOME/qnx-staging USE_INSTALL_ROOT=true` to the `make` line.

The tests go to `<install root>/x86_64/usr/local/bin/spdlog_tests/`.

## Run the tests on the target

```bash
IP=<target-ip>        # QEMU: mkqnximage --getip
TESTS=$QNX_TARGET/x86_64/usr/local/bin/spdlog_tests   # or $HOME/qnx-staging/x86_64/...
ssh root@$IP "mkdir -p /data/spdlog"
scp -r $TESTS/* root@$IP:/data/spdlog/
ssh root@$IP "TIMEOUT_SCALE=3 sh /data/spdlog/qnxtests.sh"
```

Each test prints a `PASS`/`FAIL`/`TIMEOUT` line, then a summary line. Logs are written to `/data/spdlog/logs/`.

## What is QNX-specific

- **`-lsocket`** (in `common.mk`): sendto and friends are in libsocket.so.4 on QNX, not in libc
- **`-D_QNX_SOURCE`** (in `common.mk`): a strict -std= mode hides POSIX declarations in QNX headers

| File | Change | Why (QNX behavior) |
|---|---|---|
| `include/spdlog/details/os-inl.h` | include <sys/process.h> for getpid on QNX | QNX declares getpid in <sys/process.h> (declared when defined(__EXT_POSIX1_198808)) |
