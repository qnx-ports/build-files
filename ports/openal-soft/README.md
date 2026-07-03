# openal-soft [![Build](https://github.com/qnx-ports/build-files/actions/workflows/openal-soft.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/openal-soft.yml)

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

# dependencies
# Clone stable version libsndfile
git clone -b 1.2.2 https://github.com/libsndfile/libsndfile.git

# Build libsndfile
#QNX_PROJECT_ROOT=<source_path>
make -C build-files/ports/libsndfile/ install -j4

# Clone stable version openal-soft
git clone -b v1.23.1 https://github.com/kcat/openal-soft.git

# Build openal-soft
make -C build-files/ports/openal-soft/ install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# dependencies
# Clone stable version libsndfile
git clone -b 1.2.2 https://github.com/libsndfile/libsndfile.git

# Build libsndfile
#QNX_PROJECT_ROOT=<source_path>
make -C build-files/ports/libsndfile/ install -j4

# Clone stable version openal-soft
git clone -b v1.23.1 https://github.com/kcat/openal-soft.git

# Build openal-soft
make -C build-files/ports/openal-soft/ install -j4
```

Here is a README for validating openal-soft on your QNX target, following the same format as your examples:

***

# Testing :

After building openal-soft for your QNX target, validation is straightforward. The make process already compiles test binaries and copies test data to the CPU-specific directory (nto-<cpudir>). Deploy and run tests on your target device (any QNX device with audio drivers installed).

Prerequisites:
    1. Built openal-soft artifacts in build-files/ports/openal-soft/nto-<cpudir>/
    2. Write permissions on target /tmp (or use TMPDIR=/fs/hd0/temp)
    3. SSH access to target device

1. Deploy to Target Device
```bash
TARGET_HOST=<target-ip-or-hostname>

#creating ~/guests directory on target
ssh qnxuser@$TARGET_HOST "mkdir -p ~/guests"

# Copy entire CPU directory to target
scp -r ./build-files/ports/openal-soft/nto-aarch64-le qnxuser@$TARGET_HOST:~/guests/
```
2. SSH to Target and Setup Environment
```bash
ssh qnxuser@<TARGET_HOST>
cd ~/guests/nto-aarch64-le
```
3. Run Validation Tests
```bash
# Execute openal-soft utill
./openal-info   #list all the playback and capture devices and all the capabilities.
./alrecord -c 2 -b 16 -r 48000 -t 10 -o /tmp/1.wav #record audio 
```
4. Expected Results
```text
===============================================================================
./openal-info  
Available playback devices:
    No Output
Available capture devices:
    !!! none !!!
Default playback device: No Output
Default capture device: 
ALC version: 1.1
 
** Info for device "No Output" **
ALC version: 1.1
ALC extensions:
    ALC_ENUMERATE_ALL_EXT, ALC_ENUMERATION_EXT, ALC_EXT_CAPTURE,
    ALC_EXT_DEDICATED, ALC_EXT_disconnect, ALC_EXT_EFX,
    ALC_EXT_thread_local_context, ALC_SOFT_device_clock, ALC_SOFT_HRTF,
    ALC_SOFT_loopback, ALC_SOFT_loopback_bformat, ALC_SOFT_output_limiter,
    ALC_SOFT_output_mode, ALC_SOFT_pause_device, ALC_SOFT_reopen_device
Available HRTFs:
    Built-In HRTF
Device output mode: Stereo (basic)
Device sample rate: 48000hz
OpenAL vendor string: OpenAL Community
OpenAL renderer string: OpenAL Soft
OpenAL version string: 1.1 ALSOFT 1.23.1
OpenAL extensions:
    AL_EXT_ALAW, AL_EXT_BFORMAT, AL_EXT_DOUBLE, AL_EXT_EXPONENT_DISTANCE,
    AL_EXT_FLOAT32, AL_EXT_IMA4, AL_EXT_LINEAR_DISTANCE, AL_EXT_MCFORMATS,
    AL_EXT_MULAW, AL_EXT_MULAW_BFORMAT, AL_EXT_MULAW_MCFORMATS, AL_EXT_OFFSET,
    AL_EXT_source_distance_model, AL_EXT_SOURCE_RADIUS, AL_EXT_STATIC_BUFFER,
    AL_EXT_STEREO_ANGLES, AL_LOKI_quadriphonic, AL_SOFT_bformat_ex,
    AL_SOFTX_bformat_hoa, AL_SOFT_block_alignment, AL_SOFT_buffer_length_query,
    AL_SOFT_callback_buffer, AL_SOFTX_convolution_reverb,
    AL_SOFT_deferred_updates, AL_SOFT_direct_channels,
    AL_SOFT_direct_channels_remix, AL_SOFT_effect_target, AL_SOFT_events,
    AL_SOFT_gain_clamp_ex, AL_SOFTX_hold_on_disconnect, AL_SOFT_loop_points,
    AL_SOFTX_map_buffer, AL_SOFT_MSADPCM, AL_SOFT_source_latency,
    AL_SOFT_source_length, AL_SOFT_source_resampler, AL_SOFT_source_spatialize,
    AL_SOFT_source_start_delay, AL_SOFT_UHJ, AL_SOFT_UHJ_ex
Available resamplers:
    Nearest
    Linear
    Cubic *
    11th order Sinc (fast)
    11th order Sinc
    23rd order Sinc (fast)
    23rd order Sinc
EFX version: 1.0
Max auxiliary sends: 2
Supported filters:
    Low-pass, High-pass, Band-pass
Supported effects:
    EAX Reverb, Reverb, Chorus, Distortion, Echo, Flanger, Frequency Shifter,
    Vocal Morpher, Pitch Shifter, Ring Modulator, Autowah, Compressor,
    Equalizer, Dedicated Dialog, Dedicated LFE
```
```text
===============================================================================
./alrecord -c 2 -b 16 -r 48000 -t 10 -o /tmp/1.wav
Opened "ALSA Default"

Recording '/tmp/1.wav', Signed 16-bit, Stereo, 48000hz (10 seconds)
Captured 482400 samples
```

```bash
ls -la /tmp/1.wav
-rw-rw-rw- 2 root root 1929646 2026-05-07 11:26 /tmp/1.wav
```

## Note: 
```text
To validate OpenAL, the target hardware must have a supported audio device and the corresponding audio driver installed and functioning correctly.
Above test cases are validated using AMD board.
```