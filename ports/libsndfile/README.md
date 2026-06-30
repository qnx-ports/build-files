# libsndfile [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libsndfile.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libsndfile.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

To install the library files at a specific location (e.g. `/tmp/staging`) use options INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true with the build command.

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

# Clone latest stable version libsndfile
git clone -b 1.2.2 https://github.com/libsndfile/libsndfile.git

# Build libsndfile
#QNX_PROJECT_ROOT=<source_path>
make -C build-files/ports/libsndfile/ install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone -b 1.2.2 https://github.com/libsndfile/libsndfile.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Build libsndfile
#QNX_PROJECT_ROOT=<source_path>
make -C build-files/ports/libsndfile/ install -j4 
```
Here is a README for validating libsndfile on your QNX target, following the same format as your examples:

***

# Testing

After building libsndfile for your QNX target, validation is straightforward. The make process already compiles test binaries and the shared library to the CPU-specific directory (`nto-<cpudir>`). Deploy and run tests on your target device (RPi/x86 QNX machine).

**Prerequisites:**
1. Built libsndfile artifacts in `build-files/ports/libsndfile/nto-<cpudir>/`
2. Write permissions on target `/tmp` (or use `TMPDIR=/fs/hd0/temp`)
3. SSH access to target device

***

## 1. Deploy to Target Device

```bash
TARGET_HOST=<target-ip-or-hostname>

# Copy shared library
scp libsndfile.so libsndfile.so.1 libsndfile.so.1.0.37 \
    qnxuser@$TARGET_HOST:/usr/local/lib/

# Copy test utilities
scp list_formats make_sine sndfile-info sndfile-convert \
    sndfile-cmp sndfile-metadata-get \
    qnxuser@$TARGET_HOST:/usr/local/bin/
```

***

## 2. SSH to Target and Setup Environment

```bash
ssh qnxuser@$TARGET_HOST

# Set library path so binaries can locate libsndfile.so at runtime
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Make binaries executable (if not already)
chmod +x /usr/local/bin/sndfile-*
chmod +x /usr/local/bin/list_formats
chmod +x /usr/local/bin/make_sine
```

***

## 3. Run Validation Tests

```bash
# 1. Verify shared library loads and all supported formats are listed
list_formats

# 2. Generate a test WAV file (sine wave) — confirms encode path works
make_sine /tmp/test_sine.wav

# 3. Inspect the generated file — confirms decode/metadata path works
sndfile-info /tmp/test_sine.wav

# 4. Convert WAV to a different format — confirms format conversion
sndfile-convert /tmp/test_sine.wav /tmp/test_sine.aiff

# 5. Compare original and a copy — confirms data integrity
sndfile-convert /tmp/test_sine.wav /tmp/test_copy.wav
sndfile-cmp /tmp/test_sine.wav /tmp/test_copy.wav

# 6. Read metadata from generated file
sndfile-metadata-get /tmp/test_sine.wav

```

***

## 4. Expected Results

```text
$ list_formats
    aiff   AIFF (Apple/SGI)
    au     AU (Sun/Next)
    avr    AVR (Audio Visual Research)
    caf    CAF (Apple Core Audio File)
    flac   FLAC (Free Lossless Audio Codec)
    htk    HTK (HMM Tool Kit)
    iff    IFF (Amiga IFF/SVX8/SV16)
    mat4   MAT4 (GNU Octave 2.0 / Matlab 4.2)
    mat5   MAT5 (GNU Octave 2.1 / Matlab 5.0)
    mpc2k  MPC (Akai MPC 2000)
    nist   NIST/Sphere
    paf    PAF (Ensoniq PARIS)
    pvf    PVF (Portable Voice Format)
    raw    RAW (header-less)
    rf64   RF64 (RIFF 64)
    sd2    SD2 (Sound Designer II)
    sds    SDS (Midi Sample Dump Standard)
    svx    IFF (Amiga IFF/SVX8/SV16)
    voc    VOC (Creative Labs)
    vox    VOX (Dialogic/OKI ADPCM)
    w64    W64 (SoundFoundry WAVE 64)
    wav    WAV (Microsoft)
    wavex  WAVEX (Microsoft)
    wve    WVE (Psion Series 3)
    xi     XI (FastTracker 2)

$ make_sine /tmp/test_sine.wav
    # No output — exit code 0 indicates success

$ sndfile-info /tmp/test_sine.wav

========================================
File : /tmp/test_sine.wav
Length : 48044 bytes
MIME Type : audio/x-wav

Sample Rate : 44100
Frames      : 4410
Channels    : 1
Format      : 0x00010002
Sections    : 1
Seekable    : TRUE
Duration    : 00:00:00.100

Signal Max  : 32767 (0.00 dBFS)

$ sndfile-cmp /tmp/test_sine.wav /tmp/test_copy.wav
    # No output — exit code 0 means files are identical
```

***
