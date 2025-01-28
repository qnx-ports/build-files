# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone zstd
git clone https://github.com/qnx-ports/zstd.git

# Build zstd
SOURCE_ROOT="$(pwd)/zstd" OSLIST=nto make -C build-files/ports/zstd install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/zstd.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build zstd
SOURCE_ROOT="$(pwd)/zstd" OSLIST=nto make -C build-files/ports/zstd install -j4
```

Zstandard library : usage examples
==================================

- [Simple compression](simple_compression.c) :
  Compress a single file.
  Introduces usage of : `ZSTD_compress()`

- [Simple decompression](simple_decompression.c) :
  Decompress a single file.
  Only compatible with simple compression.
  Result remains in memory.
  Introduces usage of : `ZSTD_decompress()`

- [Multiple simple compression](multiple_simple_compression.c) :
  Compress multiple files (in simple mode) in a single command line.
  Demonstrates memory preservation technique that
  minimizes malloc()/free() calls by re-using existing resources.
  Introduces usage of : `ZSTD_compressCCtx()`

- [Streaming memory usage](streaming_memory_usage.c) :
  Provides amount of memory used by streaming context.
  Introduces usage of : `ZSTD_sizeof_CStream()`

- [Streaming compression](streaming_compression.c) :
  Compress a single file.
  Introduces usage of : `ZSTD_compressStream()`

- [Multiple Streaming compression](multiple_streaming_compression.c) :
  Compress multiple files (in streaming mode) in a single command line.
  Introduces memory usage preservation technique,
  reducing impact of malloc()/free() and memset() by re-using existing resources.

- [Streaming decompression](streaming_decompression.c) :
  Decompress a single file compressed by zstd.
  Compatible with both simple and streaming compression.
  Result is sent to stdout.
  Introduces usage of : `ZSTD_decompressStream()`

- [Dictionary compression](dictionary_compression.c) :
  Compress multiple files using the same dictionary.
  Introduces usage of : `ZSTD_createCDict()` and `ZSTD_compress_usingCDict()`

- [Dictionary decompression](dictionary_decompression.c) :
  Decompress multiple files using the same dictionary.
  Result remains in memory.
  Introduces usage of : `ZSTD_createDDict()` and `ZSTD_decompress_usingDDict()`