# open62541 [![Build](https://github.com/qnx-ports/build-files/actions/workflows/open62541.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/open62541.yml)

Supports QNX 8.0 (aarch64le, x86_64). Built from upstream [open62541/open62541](https://github.com/open62541/open62541) at commit [`667acbc69`](https://github.com/open62541/open62541/commit/667acbc69132d3ba5b6db17be8002cb121849d41), the merge of QNX 8.0 support for the POSIX architecture ([open62541#8702](https://github.com/open62541/open62541/pull/8702)). No release contains it yet (latest: v1.5.10). The three patches in `patches/` are open upstream (see below).

It builds the shared library `libopen62541.so` with encryption (the SDP's OpenSSL 3: the RSA SecurityPolicies Basic256Sha256, Aes128_Sha256_RsaOaep and Aes256_Sha256_RsaPss, and the ECC ones), PubSub, and the examples. With `BUILD_TESTING=ON` it also builds upstream's unit tests and installs them with a script that runs them on the target.

**NOTE**: QNX ports are only supported from a Linux host operating system.

Use `$(nproc)` instead of `4` after `JLEVEL=` if you want to use all cores.

## Patches

| Patch | Why | Upstream |
| --- | --- | --- |
| `0001-fix-arch-set-IP_MULTICAST_IF-...` | Only Linux takes `struct ip_mreqn` for `IP_MULTICAST_IF`. QNX rejects the 8-byte `struct ip_mreq` with `EADDRNOTAVAIL`, so every IPv4 multicast PubSub connection fails to open. | [open62541#8718](https://github.com/open62541/open62541/pull/8718) |
| `0002-build-link-the-rt-state-machine-...` | The example `server_pubsub_subscribe_rt_state_machine` calls the socket API itself; on QNX that is in `libsocket`. | [open62541#8719](https://github.com/open62541/open62541/pull/8719) |
| `0003-test-fix-unit-tests-that-fail-on-QNX-8.0` | Test fixes: `errno` read too late, loopback interface `lo0`, missing `netinet/in.h`, and `check_json_config_pki` not built on QNX (the certificate filestore that `pkiFolder` configures is not available there). | [open62541#8719](https://github.com/open62541/open62541/pull/8719) |

## What the recipe sets, and why

| Setting | Why |
| --- | --- |
| `BUILD_SHARED_LIBS=ON`, `-fPIC` | Shared library, as most QNX ports install. |
| `UA_ARCHITECTURE=posix` | CMake picks it on QNX 8.0 anyway; set explicitly. |
| `UA_ENABLE_ENCRYPTION=OPENSSL` with the SDP's OpenSSL | Set `UA_ENABLE_ENCRYPTION=OFF` to build without encryption. |
| `CMAKE_AR`, `CMAKE_RANLIB` = `nto<cpu>-ar`, `nto<cpu>-ranlib` | open62541 enables link-time optimisation for Release builds; the SDP's own tools handle the LTO objects. |
| `-ffile-prefix-map` | Source file names in log and assertion messages without the build host's folders. |
| `BUILD_TESTING` (default `OFF`) | `ON` builds the unit tests. They need the [check](../check/README.md) port installed first (see Tests). |

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

# Clone open62541 at the tested commit and apply the patches
cd ~/qnx_workspace
git clone https://github.com/open62541/open62541.git
cd open62541
git checkout 667acbc69132d3ba5b6db17be8002cb121849d41
git submodule update --init --recursive
git apply ../build-files/ports/open62541/patches/*.patch
cd ..

# Build and install open62541
QNX_PROJECT_ROOT="$(pwd)/open62541" JLEVEL=4 make -C build-files/ports/open62541 install
```

## Compile the port for QNX on Ubuntu host
```bash
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/open62541/open62541.git
cd open62541
git checkout 667acbc69132d3ba5b6db17be8002cb121849d41
git submodule update --init --recursive
git apply ../build-files/ports/open62541/patches/*.patch
cd ..

source ~/qnx800/qnxsdp-env.sh

QNX_PROJECT_ROOT="$(pwd)/open62541" JLEVEL=4 make -C build-files/ports/open62541 install
```

To build only one architecture, run make in its folder, e.g. `make -C build-files/ports/open62541/nto-aarch64-le install`.

Installed files:

| What | Where |
| --- | --- |
| Headers | `$QNX_TARGET/<cpu>/usr/local/include/open62541/` |
| Library | `$QNX_TARGET/<cpu>/usr/local/lib/libopen62541.so*` |
| CMake package | `$QNX_TARGET/<cpu>/usr/local/lib/cmake/open62541/` |
| Examples (not installed) | `build-files/ports/open62541/nto-<cpu>/build/bin/examples/` |
| Unit tests (`BUILD_TESTING=ON`) | `$QNX_TARGET/<cpu>/usr/local/bin/open62541_tests/` |

## Tests

The unit tests use [check](https://github.com/libcheck/check). Build its port first, then open62541 with `BUILD_TESTING=ON`:
```bash
git clone https://github.com/qnx-ports/check.git
QNX_PROJECT_ROOT="$(pwd)/check" JLEVEL=4 make -C build-files/ports/check install
BUILD_TESTING=ON QNX_PROJECT_ROOT="$(pwd)/open62541" JLEVEL=4 make -C build-files/ports/open62541 install
```

**Known issue in the check port**: its CMake build looks for `clock_gettime` and the POSIX timers only in `librt`, which QNX does not have, so `libcheck.so` exports its own replacements and they replace the libc functions in every test program. The replacement `clock_gettime` always returns 0: tests that wait for time to pass hang until the 300 s limit (e.g. `check_config_default`, `check_client_subscriptions`). Fixed in [qnx-ports/check#1](https://github.com/qnx-ports/check/pull/1).

Copy the tests and the libraries to the target, then run them from there:
```bash
TARGET_HOST=<target-ip-address-or-hostname>
ssh qnxuser@$TARGET_HOST "mkdir -p ~/o6/lib"
scp $QNX_TARGET/aarch64le/usr/local/lib/libopen62541.so* $QNX_TARGET/aarch64le/usr/local/lib/libcheck.so* qnxuser@$TARGET_HOST:~/o6/lib
scp -r $QNX_TARGET/aarch64le/usr/local/bin/open62541_tests qnxuser@$TARGET_HOST:~/o6

# On the target. Many tests use TCP port 4840: stop any OPC UA server there first.
LD_LIBRARY_PATH=~/o6/lib sh ~/o6/open62541_tests/qnxtests.sh
```

`qnxtests.sh` runs each test program with CTest's 300 s limit and skips the six that load NodeSet files from the build host's source tree through paths compiled into them.

## Tested

On a Raspberry Pi 4 with QNX 8.0 (aarch64le), built from fresh clones as above, with the check port including the fix mentioned under Tests:

| Test | Result |
| --- | --- |
| Unit tests (`qnxtests.sh`) | 202 programs: 193 passed, 6 skipped (source-tree paths), 3 failed, explained below |
| Interoperability: example `server_encryption` (RSA certificate it generates itself) with the Python client [asyncua](https://github.com/FreeOpcUa/opcua-asyncio) 1.1.6 from a Linux host | connects, reads the server status and namespaces, and browses with SecurityMode None, Basic256Sha256 Sign, Basic256Sha256 SignAndEncrypt and Aes128_Sha256_RsaOaep SignAndEncrypt |

The three failures depend on the test machine, not on the port:

| Test | Why |
| --- | --- |
| `check_pubsub_connection_udp` (2 of 15 checks) | IPv6 multicast needs a route for `ff00::/8`. With `route add -inet6 -net ff00:: -prefixlen 8 -interface <if>` all 15 pass. |
| `check_server_filetransfer` (2 of 104 checks) | On this image `/tmp` is a link to `/data/var/tmp`, and `symlink()` with a path through that link fails with `ENOSYS`; the same call with the path inside `/data/var/tmp` works. |
| `check_client` (1 of 48 checks) | `Client_reconnectAbortKeepsSession` failed once; it passed in three runs after that. |
