# liboqs QNX Port

This directory provides QNX build-files integration for liboqs 0.16.0, laid out like other CMake ports in qnx-ports/build-files.

Status: built with QNX SDP 8.0 (qcc 12.2.0) for `nto-x86_64-o` and `nto-aarch64-le`. The x86_64 test programs pass on a QNX 8.0.0 target. The aarch64le build has not been run on a target yet.

## Prerequisites

1. QNX Software Development Platform (SDP) 8.0 installed on a Linux host. Check the SDP 8.0 release notes for supported host OS releases.
2. Host tools: CMake 3.15 or newer (liboqs 0.16.0 `cmake_minimum_required`; 3.18 only with CUDA, which this port does not use), GNU Make.

## Environment Setup

Initialize your QNX build environment by sourcing the SDP environment script:

```bash
source ~/qnx800/qnxsdp-env.sh
```

Verify that `QNX_HOST` and `QNX_TARGET` environment variables are properly exported:

```bash
echo "QNX_HOST:   $QNX_HOST"
echo "QNX_TARGET: $QNX_TARGET"
```

## Source Tree Layout

In accordance with qnx-ports conventions, upstream liboqs source is expected to reside adjacent to the ports tree:

```
workspace/
|-- build-files/
|   \-- ports/
|       \-- liboqs/
|           |-- Makefile
|           |-- common.mk
|           |-- qnx.nto.toolchain.cmake
|           |-- nto-x86_64-o/
|           \-- nto-aarch64-le/
\-- liboqs/
```

Clone liboqs version 0.16.0 alongside `build-files`:

```bash
git clone --branch 0.16.0 https://github.com/open-quantum-safe/liboqs.git
```

To build a liboqs checkout from another location, set `QNX_PROJECT_ROOT`:

```bash
QNX_PROJECT_ROOT=/path/to/liboqs make -C build-files/ports/liboqs install JLEVEL=4
```

## Build and Installation

From the workspace root or build-files tree, invoke make:

```bash
# Build and install for both x86_64 and aarch64 targets
make -C build-files/ports/liboqs install JLEVEL=4
```

To build for a specific target architecture only:

```bash
# For aarch64 little-endian:
make -C build-files/ports/liboqs/nto-aarch64-le install JLEVEL=4

# For x86_64:
make -C build-files/ports/liboqs/nto-x86_64-o install JLEVEL=4
```

The install step puts `liboqs.a`, the CMake package files and `liboqs.pc` in `$QNX_TARGET/<cpu>/usr/local/lib` and the headers in `$QNX_TARGET/usr/local/include`.

## Minimal Generic C Build Configuration

The port builds only the six NIST-standardized ML-KEM and ML-DSA parameter sets, in portable C:
- Static library by default: `BUILD_SHARED_LIBS ?= OFF` (override on the make command line)
- OpenSSL dependency removed: `OQS_USE_OPENSSL=OFF`
- Generic C implementation: `OQS_DIST_BUILD=OFF`, `OQS_OPT_TARGET=generic`
- Architecture-specific vector extensions disabled: all 12 `OQS_ENABLE_KEM_*_{x86_64,aarch64}` and `OQS_ENABLE_SIG_*_{x86_64,aarch64}` options are set to `OFF`
- 6 algorithms enabled:
  - KEM: `ML-KEM-512`, `ML-KEM-768`, `ML-KEM-1024` (FIPS 203)
  - Signature: `ML-DSA-44`, `ML-DSA-65`, `ML-DSA-87` (FIPS 204)

## Target Deployment and Verification

The upstream test programs are built because `OQS_BUILD_ONLY_LIB=OFF`. The library is static, so only the test executables go to the target. Each per-CPU directory has its own `build-port/`.

1. Copy the test executables to the QNX target (x86_64 shown):

```bash
cd build-files/ports/liboqs/nto-x86_64-o/build-port
scp tests/test_kem tests/test_sig tests/kat_kem tests/kat_sig qnx-target:/data/oqs/
```

2. Run them on the target. `test_kem` and `test_sig` take one algorithm name per run:

```bash
cd /data/oqs
for a in ML-KEM-512 ML-KEM-768 ML-KEM-1024; do ./test_kem "$a"; done
for a in ML-DSA-44 ML-DSA-65 ML-DSA-87; do ./test_sig "$a"; done
```

ACVP vector checks are outside this port.
