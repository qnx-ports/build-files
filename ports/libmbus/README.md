# libmbus [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libmbus.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libmbus.yml)

Supports QNX 8.0 (aarch64le, x86_64). Built from upstream [rscada/libmbus](https://github.com/rscada/libmbus) `0.10.4` (latest release, 2026-10-20) with no source patches: the M-Bus (EN 13757-2/-3) master library, its serial and TCP command-line tools (`mbus-serial-request-data`, `mbus-tcp-scan`, ...) and, with `BUILD_TESTING=ON`, upstream's frame-parsing tests.

**NOTE**: QNX ports are only supported from a Linux host operating system.

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use all cores.

## What the recipe sets, and why

| Setting | Why |
| --- | --- |
| `LIBS=-lsocket` | `socket()`, `connect()` and `getaddrinfo()` are in `libsocket` on QNX; `configure.ac` does not look for them, and the library is linked with `-no-undefined`. Fix proposed upstream: [libmbus#247](https://github.com/rscada/libmbus/pull/247) (open). |
| `mkdir -p m4 && autoreconf -fi` | The git tree has no `configure`. `configure.ac` names an `m4` folder that is not in git, and `aclocal` treats its absence as an error. Needs autoconf, automake and libtool on the host (the qnx-ports Docker image has them). |
| `-ffile-prefix-map` | Source file names in messages without the build host's folders. |

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

# Clone libmbus
cd ~/qnx_workspace
git clone https://github.com/rscada/libmbus.git
cd libmbus && git checkout 0.10.4 && cd ..

# Build and install libmbus (plus the frame tests)
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/libmbus" JLEVEL=4 make -C build-files/ports/libmbus install
```

To build only one architecture, run make in its folder, e.g. `make -C build-files/ports/libmbus/nto-aarch64-le install`.

Installed files:

| What | Where |
| --- | --- |
| Headers | `$QNX_TARGET/usr/local/include/mbus/` |
| Library | `$QNX_TARGET/<cpu>/usr/local/lib/libmbus.so*` |
| Tools | `$QNX_TARGET/<cpu>/usr/local/bin/mbus-*` |
| pkg-config | `$QNX_TARGET/<cpu>/usr/local/lib/pkgconfig/libmbus.pc` |
| Tests (`BUILD_TESTING=ON`) | `$QNX_TARGET/<cpu>/usr/local/bin/libmbus_tests/` |

## Deploy and test on the target
```bash
TARGET_HOST=<target-ip-address-or-hostname>

ssh qnxuser@$TARGET_HOST "mkdir -p ~/lib"
scp $QNX_TARGET/aarch64le/usr/local/lib/libmbus.so* qnxuser@$TARGET_HOST:~/lib
scp -r $QNX_TARGET/aarch64le/usr/local/bin/libmbus_tests qnxuser@$TARGET_HOST:~/

# on the target
cd ~/libmbus_tests && LD_LIBRARY_PATH=~/lib sh qnxtests.sh
```

`qnxtests.sh` runs upstream's `generate-xml.sh` over the three frame sets:

| Set | Expected | Raspberry Pi 4, QNX 8.0 |
| --- | --- | --- |
| `test-frames` (78 frames from real meters) | every frame parses to the XML upstream recorded, raw and normalised | PASS |
| `error-frames` (20 frames) | 30 runs fail to parse, as on Linux | PASS |
| `unsupported-frames` (7 frames) | 12 runs fail to parse, as on Linux | PASS |

The expected failure counts are those of the same tests built for Linux x86_64 from the same tag.

Also tested on the Pi: a program linking this library reads a simulated meter over M-Bus TCP (REQ_UD2, variable data structure) every 10 s.
