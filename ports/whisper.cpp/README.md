# whisper.cpp [![Build](https://github.com/qnx-ports/build-files/actions/workflows/whisper.cpp.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/whisper.cpp.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

whisper.cpp is a C/C++ implementation of OpenAI's Whisper speech-to-text model that runs fully on-device with no GPU or internet required.

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

# Clone whisper.cpp
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/whisper.cpp.git

# Build whisper.cpp
QNX_PROJECT_ROOT="$(pwd)/whisper.cpp" make -C build-files/ports/whisper.cpp install -j4
```

# Compile the port for QNX on a host machine
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/whisper.cpp.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build whisper.cpp
QNX_PROJECT_ROOT="$(pwd)/whisper.cpp" make -C build-files/ports/whisper.cpp install -j4
```

# Download a model

whisper.cpp requires a GGML-format Whisper model. You can download one on your host:
```bash
cd ~/qnx_workspace/whisper.cpp/models
./download-ggml-model.sh tiny.en
```

# How to run on the target

Transfer the binaries, libraries, model, and test audio to the target:
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Transfer whisper binaries
scp $QNX_TARGET/aarch64le/usr/local/bin/whisper-* qnxuser@$TARGET_HOST:/data/home/qnxuser/

# Transfer shared libraries
scp $QNX_TARGET/aarch64le/usr/local/lib/libwhisper* qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp $QNX_TARGET/aarch64le/usr/local/lib/libggml* qnxuser@$TARGET_HOST:/data/home/qnxuser/

# Transfer model and test audio
scp ~/qnx_workspace/whisper.cpp/models/ggml-tiny.en.bin qnxuser@$TARGET_HOST:/data/home/qnxuser/
scp ~/qnx_workspace/whisper.cpp/samples/jfk.wav qnxuser@$TARGET_HOST:/data/home/qnxuser/
```

Run on the target:
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Set library path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/home/qnxuser
export GGML_BACKEND_PATH=/data/home/qnxuser

# Run speech-to-text
cd /data/home/qnxuser
./whisper-cli -m ggml-tiny.en.bin jfk.wav

# Run benchmark
./whisper-bench -m ggml-tiny.en.bin
```

## Supported architectures
- aarch64le
- x86_64
