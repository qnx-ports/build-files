# WebRTC

**Note**: QNX ports are only supported from a **Linux host** operating system

# Pre-requisite

## Depot Tools

Refer to the Linux installation [guide](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up) to install the Chromium depot tools.
**NOTE**: Depot Tools is preinstalled in the Docker image.

## Lbraries

A script named install-build-deps.sh is provided to install all the libraries required for building WebRTC. This script is part of the WebRTC repository, so you must clone the repository before you can run it.
**NOTE**: required libraies are preinstalled in the Docker image.

# Compile the port for QNX in a Docker container

Refer to the [guide](https://github.com/qnx-ports/build-files/blob/main/docker/README.md) to start a docker container, then attach to it. Use the following commands from the container's console to clone and build WebRTC.

```
# Clone WebRTC
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/webrtc.git
gclient config --name=src --unmanaged --custom-var checkout_qnx=True https://github.com/qnx-ports/webrtc.git
echo "target_os = [\"qnx\"]" >> .gclient
gclient sync
cd src

# Build WebRTC
make
```

# Compile the port for QNX on Ubuntu host

Unlike building WebRTC with containers, building WebRTC on the host requires an additional [pre-requisite](#pre-requisite) step. If you haven't already installed [Depot Tools](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up), please do so before proceeding to the next step.
Assuming that you have installed SDP8 in the directory `~/qnx800` and created the `~/qnx_workspace` directory as your workspace, use the following commands in the host console to clone and build WebRTC:
```
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Clone WebRTC
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/webrtc.git
gclient config --name=src --unmanaged --custom-var checkout_qnx=True https://github.com/qnx-ports/webrtc.git
echo "target_os = [\"qnx\"]" >> .gclient
gclient sync
cd src

# Install the required libraries (one-time setup)
./build/install-build-deps.sh

# Build WebRTC
make
```

# How to run tests

**Note**: To run tests on the target device, the audio and camera components must be properly configured.

## Copy test resources to target

Depending on the network and audio libraries that WebRTC is built on, the WebRTC binaries are located in the following subdirectories of `<WEBRTC_ROOT>/out`.

```
nto-x86_64-o-iopkt-ioaudio
nto-x86_64-o-iopkt-iosnd
nto-x86_64-o-iosock-ioaudio
nto-x86_64-o-iosock-iosnd
nto-aarch64-le-iopkt-ioaudio
nto-aarch64-le-iopkt-iosnd
nto-aarch64-le-iosock-ioaudio
nto-aarch64-le-iosock-iosnd
```
You must select the appropriate binaries based on the network and audio services running on the target device. For example, if io-snd and io-sock are running on an AArch64 target, you should copy the binaries from the nto-aarch64-le-iosock-iosnd subdirectory. The script `webrtc-copy-test-resources-to-target.sh` helps you copy all the required resources to the target directory.
You can view usage instructions with the following command:

```
scripts/webrtc-copy-test-resources-to-target.sh
usage: webrtc-copy-test-resources-to-target.sh <BINARY DIR> <TARGET DIR> <IP ADDRESS> [USER] [PASSWORD]
```

Assuming the target CPU is aarch64, and the io-sock and io-snd services are running on the target, with the target IP address set to 10.122.11.3, and you wish to copy the testing resources to the target directory `/data/home/qnxuser/webrtc`, where the target username and password are both qnxuser, you can execute the following command:

```
out/scripts/webrtc-copy-test-resources-to-target.sh ./nto-aarch64-le-iosock-iosnd /data/home/qnxuser/webrtc 10.122.11.3 qnxuser qnxuser
```
**NOTE**: If no username or password is provided, the default credentials (username/password) are root/root.

## Run tests

Assuming all testing resources are located in the target directory `/data/home/qnxuser/webrtc`, you can initiate the tests using the following commands from the target console:
```
cd /data/home/qnxuser/webrtc/out/cpu
./run-all-tests.sh
```
**NOTE**: `run-all-tests.sh` requires tee. If it's not available on the target, you can copy it from `${QNX_TARGET}/<CPU>/usr/bin/tee`.

## Check results

The console outputs and results are available in the target directory: `/data/home/qnxuser/webrtc/out/cpu/result`.
