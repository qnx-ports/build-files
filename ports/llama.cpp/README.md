# llama.cpp

[llama.cpp](https://github.com/ggml-org/llama.cpp) is LLM inference in C/C++. This port builds the CPU backend, the `llama` and `ggml` libraries, and the tools (`llama-server` with its OpenAI-compatible HTTP API, `llama-cli`, `llama-completion`, `llama-bench` and others) for QNX 8.0.

**NOTE**: QNX ports are only supported from Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.

To install the library files at a specific location (e.g. `/tmp/staging`) use options `INSTALL_ROOT_nto=<staging-install-folder>` and `USE_INSTALL_ROOT=true` with the build command.

`qnx.patch` (six small changes, each guarded by `__QNX__`, `CMAKE_SYSTEM_NAME STREQUAL "QNX"` or `#ifdef SA_RESTART`, so other platforms are unaffected) is applied to the upstream checkout automatically:

- `ggml-cpu.cpp`: QNX has no `_SC_PHYS_PAGES`. Device memory comes from the system page (`SYSPAGE_ENTRY(asinfo)`), and free memory from `/proc`.
- `common/download.cpp`: `PATH_MAX` is in `<limits.h>` on QNX.
- `vendor/sheredom/subprocess.h`: QNX has `posix_spawn` but no `posix_spawn_file_actions_addchdir_np`.
- `vendor/cpp-httplib/CMakeLists.txt`, `common/CMakeLists.txt`: link `libsocket`.
- `tools/quantize/quantize.cpp`: use `SA_RESTART` only where it is defined (QNX 8.0 does not support it).

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
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone llama.cpp
git clone -b b12778 https://github.com/ggml-org/llama.cpp.git

# Build llama.cpp
make -C build-files/ports/llama.cpp install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b b12778 https://github.com/ggml-org/llama.cpp.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build
QNX_PROJECT_ROOT="$(pwd)/llama.cpp" make -C build-files/ports/llama.cpp install JLEVEL=4
```

On x86_64 the build enables AVX2, FMA and F16C. To change that, pass `GGML_X86_FLAGS="..."` to make.

# How to run

Copy the binaries and libraries to the target. A QEMU image needs a data partition big enough for a model: `mkqnximage --type=qemu --arch=x86_64 --data-size=3000 --data-inodes=20000`.

```bash
TARGET_HOST=<target-ip-address-or-hostname>
ARCH=x86_64   # or aarch64le
scp $QNX_TARGET/$ARCH/usr/local/bin/llama-* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin
scp $QNX_TARGET/$ARCH/usr/local/lib/*.so* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp <model>.gguf qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

On the target:

```bash
export LD_LIBRARY_PATH=/data/home/qnxuser/lib:$LD_LIBRARY_PATH
cd /data/home/qnxuser
bin/llama-bench -m <model>.gguf -t 2 -p 64 -n 32
bin/llama-server -m <model>.gguf -c 4096 -t 2 --host 0.0.0.0 --port 8081 --jinja
```

Always pass a context size (`-c`). Otherwise llama.cpp sizes the context from the model's maximum, which can exceed a small target's memory.

The tools are split into shared libraries (for example `libllama-server-impl.so`), so copy every `.so` file from `lib`, not only `libllama` and `libggml`.

Tested on QNX 8.0 x86_64 (QEMU/KVM, 2 vCPUs) with Qwen3-1.7B and Qwen2.5-1.5B (Q4_K_M):
- `llama-bench`: prompt processing 40–58 tokens/s, generation 12–21 tokens/s, depending on the host CPU;
- `llama-server`: chat completions, including tool calling.

aarch64le builds; reports from Raspberry Pi 4/5 are welcome.
