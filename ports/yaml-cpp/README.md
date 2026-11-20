# yaml-cpp for QNX

[yaml-cpp](https://github.com/jbeder/yaml-cpp) built for QNX 8.0. Port generated and verified by PortPilot.

| | |
|---|---|
| Tested | QNX SDP 8.0, x86_64, QEMU target |
| Upstream | `yaml-cpp-0.9.0` |

**NOTE**: QNX ports are only supported from a Linux host operating system

## Create a workspace

```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/jbeder/yaml-cpp yaml-cpp
git -C yaml-cpp checkout yaml-cpp-0.9.0
git clone https://github.com/qnx-ports/muslflt.git muslflt   # dependency: the official muslflt port
```

## Build

```bash
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt install JLEVEL=$(nproc)
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/yaml-cpp" \
  make -C build-files/ports/yaml-cpp install JLEVEL=$(nproc)
```

This installs into the SDP, as the other ports do. To use a staging area instead, add `INSTALL_ROOT_nto=$HOME/qnx-staging USE_INSTALL_ROOT=true` to every `make` line.

The tests go to `<install root>/x86_64/usr/local/bin/yaml-cpp_tests/`.

## Run the tests on the target

```bash
IP=<target-ip>        # QEMU: mkqnximage --getip
TESTS=$QNX_TARGET/x86_64/usr/local/bin/yaml-cpp_tests   # or $HOME/qnx-staging/x86_64/...
ssh root@$IP "mkdir -p /data/yaml-cpp"
scp -r $TESTS/* root@$IP:/data/yaml-cpp/
ssh root@$IP "TIMEOUT_SCALE=3 sh /data/yaml-cpp/qnxtests.sh"
```

Each test prints a `PASS`/`FAIL`/`TIMEOUT` line, then a summary line. Logs are written to `/data/yaml-cpp/logs/`.

## What is QNX-specific

- **`-Wno-narrowing`** (in `common.mk`): char is unsigned on aarch64; the code puts negative constants in char arrays (same bytes)
- **muslflt** (in `project_hooks.cmake`): tests expect glibc-style float output; QNX libc prints valid but different digits.
