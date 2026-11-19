# bacnet-stack [![Build](https://github.com/qnx-ports/build-files/actions/workflows/bacnet-stack.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/bacnet-stack.yml)

Supports QNX 8.0 (aarch64le, x86_64), BACnet/IP. Built from upstream [bacnet-stack/bacnet-stack](https://github.com/bacnet-stack/bacnet-stack) with no source patches: since commit `dab1ea2f2` ([#1606](https://github.com/bacnet-stack/bacnet-stack/pull/1606), November 2026) bacnet-stack's own Makefile builds for QNX 8.0 with `BACNET_PORT=qnx`, using its `ports/bsd` code. No release has that commit yet, so check out `master` (or `dab1ea2f2`) until one does.

**NOTE**: QNX ports are only supported from a Linux host operating system.

The build always runs with `-j1`, whatever `JLEVEL` says: several bacnet-stack applications compile the same object files, so a parallel build races on them.

## Compile the port for QNX in a Docker container

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
source ~/qnx800/qnxsdp-env.sh

# Clone bacnet-stack
cd ~/qnx_workspace
git clone https://github.com/bacnet-stack/bacnet-stack.git

# Build and install bacnet-stack
QNX_PROJECT_ROOT="$(pwd)/bacnet-stack" make -C build-files/ports/bacnet-stack install
```

## Compile the port for QNX on Ubuntu host
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/bacnet-stack/bacnet-stack.git

source ~/qnx800/qnxsdp-env.sh

QNX_PROJECT_ROOT="$(pwd)/bacnet-stack" make -C build-files/ports/bacnet-stack install
```

To build only one architecture, run make in its folder, e.g. `make -C build-files/ports/bacnet-stack/nto-aarch64-le install`.
To install into a staging folder instead of `$QNX_TARGET`, add `USE_INSTALL_ROOT=true INSTALL_ROOT_nto=<staging-install-folder>` to the `make` command line (not the environment: the SDK's makefiles set `INSTALL_ROOT_nto` themselves).

Installed files:

| What | Where |
| --- | --- |
| Applications (`bacrp`, `bacwp`, `bacwi`, `bacserv`, `bacepics`, ... 48 in all) | `$QNX_TARGET/<cpu>/usr/local/bin/` |
| Static library, built for BACnet/IP | `$QNX_TARGET/<cpu>/usr/local/lib/libbacnet.a` |
| Headers | `$QNX_TARGET/usr/local/include/bacnet/` |

Programs that link `libbacnet.a` need the same data-link defines the library was built with (`-DBACDL_BIP=1` and the defaults in bacnet-stack's `apps/Makefile`). The simplest way to build one is as a bacnet-stack app, next to the ones in `apps/`.

## Deploy binaries via SSH
```bash
TARGET_HOST=<target-ip-address-or-hostname>

scp $QNX_TARGET/aarch64le/usr/local/bin/bac* qnxuser@$TARGET_HOST:~/
```

## Run on the target

Set `BACNET_IFACE` to the QNX network interface (see `ifconfig`), e.g. `bcm0` on a Raspberry Pi 4 on Wi-Fi:
```bash
export BACNET_IFACE=bcm0
./bacwi                                                  # discover devices
./bacrp 1001 device 1001 object-name                     # read a property
./bacwp 1001 analog-value 1 present-value 16 -1 4 22.5   # write a value at priority 16
./bacserv 3001 QNX-DEVICE                                # run a BACnet device on QNX
```

To run a client while another program on the same host holds UDP port 47808, give the client another port and address the device directly:
```bash
BACNET_IP_PORT=47810 ./bacrp --mac 192.168.1.20:47808 --dnet 0 1001 device 1001 object-name
```

## QNX notes

- Only BACnet/IP (`BACDL=bip`) is supported. BACnet/IPv6, MS/TP and BACnet/SC are not built for QNX by bacnet-stack yet.
- The socket API, `getifaddrs` and `sysctl` are in `libsocket` on QNX; bacnet-stack's Makefile adds it.

## Known test result on QNX 8.0

Raspberry Pi 4B, QNX 8.0.0, aarch64le, built with SDP 8.0 `qcc` (gcc 12.2.0) from bacnet-stack `dab1ea2f2`, 2026-11-09:

| Test | Result |
| --- | --- |
| Build, aarch64le and x86_64 | 48 applications each, no compiler warnings |
| `bacrp`, `bacwp`, `bacwi` against a Linux BACnet/IP device | PASS (read, write at priority 14, relinquish, Who-Is) |
| `bacrp` against `bacserv` running on the same QNX target | PASS |
