# wamr [![Build](https://github.com/qnx-ports/build-files/actions/workflows/wamr.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/wamr.yml)

**WebAssembly Micro Runtime (WAMR) for QNX 8.0.**

This port builds the [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime) interpreter
(`iwasm`) and the `libiwasm.a` runtime library for `nto x86_64` and `nto aarch64le`.

## Dependency on the upstream QNX platform support

**WAMR has no QNX platform layer upstream yet.** The `core/shared/platform/qnx/` and
`product-mini/platforms/qnx/` directories this recipe builds do not exist in the
`bytecodealliance/wasm-micro-runtime` tree today; they are proposed by

> [bytecodealliance/wasm-micro-runtime#5200 — "Add QNX 8.0 platform support"](https://github.com/bytecodealliance/wasm-micro-runtime/pull/5200)

(open, mergeable, and the only way this port can exist). Until that pull request is merged,
`QNX_PROJECT_ROOT` must point at a WAMR tree that **already contains the QNX platform support** —
for example the branch of the pull request:

```bash
git clone --branch qnx-platform https://github.com/altinayselman/wasm-micro-runtime.git
```

The CI workflow below checks out exactly that branch. Once #5200 is merged, change the checkout
to the upstream tag and this note disappears.

## QNX Software Center (QSC) compatibility warning

QNX Software Center ships its own `libiwasm.a` / `iwasm` in some SDP images. Installing this port
may therefore introduce a linking conflict at runtime. Check which version of the library your
software was cross-compiled against, and set the appropriate `LD_LIBRARY_PATH` for the dynamic
linker. This port is **not** an update of the QSC-provided library: it installs its own
`usr/local/lib/libiwasm.a` and `usr/local/bin/iwasm`.

**NOTE: QNX ports are only supported from a Linux host operating system.**

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of
cores to build this project.

# Compile the port for QNX in a Docker container

Pre-requisite: install Docker on Ubuntu — https://docs.docker.com/engine/install/ubuntu/

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone WAMR **with the QNX platform support** (see the dependency note above)
cd ~/qnx_workspace
git clone --branch qnx-platform https://github.com/altinayselman/wasm-micro-runtime.git wasm-micro-runtime
cd ..

# Build wamr
JLEVEL=$(nproc) QNX_PROJECT_ROOT="$(pwd)/wasm-micro-runtime" make -C build-files/ports/wamr install
```

# Compile the port for QNX on a host

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone WAMR **with the QNX platform support**
cd ~/qnx_workspace
git clone --branch qnx-platform https://github.com/altinayselman/wasm-micro-runtime.git wasm-micro-runtime
cd ..

# Build wamr
JLEVEL=$(nproc) QNX_PROJECT_ROOT="$(pwd)/wasm-micro-runtime" make -C build-files/ports/wamr install
```

# What gets installed

| Path | Content |
|---|---|
| `usr/local/bin/iwasm` | the QNX interpreter (bytecode and AOT loader) |
| `usr/local/lib/libiwasm.a` | the runtime library, for linking into your own host programs |
| `usr/local/include/wasm_export.h` | the public embedding API |
| `usr/local/lib/cmake/iwasm/` | CMake package configuration files |

# Build options

The build options are WAMR's own, and can be overridden on the `make` command line, for example:

```bash
JLEVEL=$(nproc) \
WAMR_BUILD_LIBC_WASI=0 \
WAMR_BUILD_LIB_PTHREAD=0 \
QNX_PROJECT_ROOT="$(pwd)/wasm-micro-runtime" \
make -C build-files/ports/wamr install
```

| Option | Default | Meaning |
|---|---|---|
| `WAMR_BUILD_INTERP` | 1 | the bytecode interpreter |
| `WAMR_BUILD_FAST_INTERP` | 1 | the fast interpreter |
| `WAMR_BUILD_AOT` | 1 | the AOT loader (the AOT *compiler* `wamrc` needs LLVM and is not built here) |
| `WAMR_BUILD_JIT` | 0 | the LLVM JIT is not built: it needs LLVM |
| `WAMR_BUILD_LIBC_BUILTIN` | 1 | WAMR's own minimal libc |
| `WAMR_BUILD_LIBC_WASI` | 1 | WASI preview 1 |
| `WAMR_BUILD_LIB_PTHREAD` | 1 | the pthread library |
| `WAMR_BUILD_DUMP_CALL_STACK` | 1 | call-stack dumping, for post-mortem analysis |

# Supported targets

`nto x86_64` and `nto aarch64le`, QNX SDP 8.0. The aarch64le target is built and installed but
has not been run on hardware.

# Notes

- The QNX platform layer reuses WAMR's existing POSIX layer; QNX keeps the BSD socket API in
  `libsocket`, while pthreads, `dlopen()` and the clocks live in `libc`.
- `MAP_32BIT` does not exist on QNX; the port uses QNX's `MAP_BELOW` flag instead, so the
  low-2 GB code region for AOT is preserved.
- QNX has no `pthread_getattr_np()`; the native stack bounds are read from thread-local storage
  so that the stack guard pages can still be placed.
