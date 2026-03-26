# llama.cpp [![Build](https://github.com/qnx-ports/build-files/actions/workflows/llama.cpp.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/llama.cpp.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

llama.cpp is a C/C++ implementation of LLM inference that runs fully on-device with no GPU or internet required. Supports chat, text-to-speech, server mode, and all popular models (Llama, Qwen, Gemma, DeepSeek, etc.).

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

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

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Clone llama.cpp
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/llama.cpp.git

# Build llama.cpp
QNX_PROJECT_ROOT="$(pwd)/llama.cpp" make -C build-files/ports/llama.cpp install -j4
```

# Compile the port for QNX on a host machine
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/llama.cpp.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build llama.cpp
QNX_PROJECT_ROOT="$(pwd)/llama.cpp" make -C build-files/ports/llama.cpp install -j4
```

# Download a model

llama.cpp requires a GGUF-format model. You can download one on your host:
```bash
cd ~/qnx_workspace
# Download a small model (~500 MB)
wget https://huggingface.co/Qwen/Qwen3-0.6B-GGUF/resolve/main/qwen3-0.6b-q4_k_m.gguf
```

You can find more models on [Hugging Face](https://huggingface.co/models?search=gguf).

# How to run on the target

Transfer the binaries, libraries, and model to the target:
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer llama.cpp binaries
scp $QNX_TARGET/aarch64le/usr/local/bin/llama-cli qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp $QNX_TARGET/aarch64le/usr/local/bin/llama-server qnxuser@$TARGET_HOST:/data/home/qnxuser/

# Transfer shared libraries
scp $QNX_TARGET/aarch64le/usr/local/lib/libllama* qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp $QNX_TARGET/aarch64le/usr/local/lib/libggml* qnxuser@$TARGET_HOST:/data/home/qnxuser/

# Transfer model
scp ~/qnx_workspace/qwen3-0.6b-q4_k_m.gguf qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

Run llama-cli on the target:
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Set library path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser

# Run chat
cd /data/home/qnxuser
./llama-cli -m qwen3-0.6b-q4_k_m.gguf
```

Run llama-server on the target:
```bash
./llama-server -m qwen3-0.6b-q4_k_m.gguf --host 0.0.0.0
```
Then open a browser on your host and navigate to `http://<target-ip-address-or-hostname>:8080/`

## Supported architectures
- aarch64le
- x86_64
