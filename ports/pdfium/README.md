# pdfium [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pdfium.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pdfium.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

# Pre-requisite

## Depot Tools

Refer to the Linux installation [guide](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up) to install the Chromium depot tools.
**NOTE**: Depot Tools is preinstalled in the Docker image.

## Lbraries

A script named install-build-deps.sh is provided to install all the libraries required for building pdfium. This script is part of the pdfium repository, so you must clone the repository before you can run it.
**NOTE**: required libraies are preinstalled in the Docker image.

# Compile the port for QNX in a Docker container

Refer to the [guide](https://github.com/qnx-ports/build-files/blob/main/docker/README.md) to start a docker container, then attach to it. Use the following commands from the container's console to clone and build pdfium.

```
# Clone pdfium
cd ~/qnx_workspace
gclient config --unmanaged --custom-var checkout_qnx=True https://github.com/qnx-ports/pdfium.git
echo "target_os = [\"qnx\"]" >> .gclient
gclient sync
cd pdfium

# Build pdfium
make
```

# Compile the port for QNX on Ubuntu host

Unlike building pdfium with containers, building pdfium on the host requires an additional [pre-requisite](#pre-requisite) step. If you haven't already installed [Depot Tools](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up), please do so before proceeding to the next step.
Assuming that you have installed SDP8 in the directory `~/qnx800` and created the `~/qnx_workspace` directory as your workspace, use the following commands in the host console to clone and build pdfium:
```
# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Clone pdfium
cd ~/qnx_workspace
gclient config --unmanaged --custom-var checkout_qnx=True https://github.com/qnx-ports/pdfium.git
echo "target_os = [\"qnx\"]" >> .gclient
gclient sync
cd pdfium

# Install the required libraries (one-time setup)
./build/install-build-deps.sh

# Build pdfium
make
```

# How to run tests

## Copy test resources to target

The pdfium binaries are located in the directory `<PDFIUM_ROOT>/out`. The script `pdfium-copy-test-resources-to-target.sh` helps you copy all the required resources to the target directory.
You can view usage instructions with the following command:

```
cd <PDFIUM_ROOT>/out
./scripts/pdfium-copy-test-resources-to-target.sh
usage: pdfium-copy-test-resources-to-target.sh <BINARY DIR> <TARGET DIR> <IP ADDRESS> [USER] [PASSWORD]
```

Assuming the target CPU is aarch64, the target IP address set to 10.122.11.3, and you wish to copy the testing resources to the target directory `/data/home/qnxuser/pdfium`, where the target username and password are both qnxuser, you can execute the following command:

```
./scripts/pdfium-copy-test-resources-to-target.sh ./nto-aarch64-le /data/home/qnxuser/pdfium 10.122.11.3 qnxuser qnxuser
```
**NOTE**: If no username or password is provided, the default credentials (username/password) are root/root.

## Run tests

Assuming all testing resources are located in the target directory `/data/home/qnxuser/pdfium`, you can initiate the tests using the following commands from the target console:
```
cd /data/home/qnxuser/pdfium
./run-all-tests.sh
```
**NOTE**: `run-all-tests.sh` requires tee. If it's not available on the target, you can copy it from `${QNX_TARGET}/<CPU>/usr/bin/tee`.

## Check results

The console outputs and results are available in the target directory: `/data/home/qnxuser/pdfium/result`.
