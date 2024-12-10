# azure-iot-sdk-c [![Build](https://github.com/qnx-ports/build-files/actions/workflows/azure-iot-sdk-c.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/azure-iot-sdk-c.yml)

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

You can optionally set up a staging area folder (e.g. `/tmp/staging`) for `<staging-install-folder>`

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone azure-iot-sdk-c
git clone https://github.com/qnx-ports/azure-iot-sdk-c.git && cd azure-iot-sdk-c
git submodule update --init --recursive
cd -

# Apply third_party patches
cd ~/qnx_workspace/build-files/ports/azure-iot-sdk-c
./scripts/patch.sh ~/qnx_workspace/azure-iot-sdk-c

# Build azure-iot-sdk-c
QNX_PROJECT_ROOT="$(pwd)/azure-iot-sdk-c" make -C build-files/ports/azure-iot-sdk-c/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/azure-iot-sdk-c.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Clone azure-iot-sdk-c
git clone https://github.com/qnx-ports/azure-iot-sdk-c.git && cd azure-iot-sdk-c
git submodule update --init --recursive
cd -

# Apply third_party patches
cd ~/qnx_workspace/build-files/ports/azure-iot-sdk-c
./scripts/patch.sh ~/qnx_workspace/azure-iot-sdk-c

# Build
QNX_PROJECT_ROOT="$(pwd)/azure-iot-sdk-c" make -C build-files/ports/azure-iot-sdk-c/ INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# How to run tests

**Note**: Below steps are for running the tests on a RPi4 target.

Move the libraries and tests to the target
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move the test binaries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/azure-iot-sdk-c/tests/* qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Move azure-iot-sdk-c libraries to the target
scp -r $QNX_TARGET/aarch64le/usr/local/lib/* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

Run the tests
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run tests
find . -maxdepth 1 -type f -executable -exec sh -c 'echo "Running $1..." >> output.txt; $1 >> output.txt 2>&1' _ {} \;
```
Known test failures

- Only two tests should fail:
    - AgentTypeSystem_CreateAgentDataType_From_String_EDM_DOUBLE_Max_Positive_Value_Succeeds fails due to overflow
    - AgentTypeSystem_CreateAgentDataType_From_String_EDM_SINGLE_Min_Positive_Value_Succeeds fails due to floating point error
- Currently, e2e tests are not built or run because they require an Azure account, see https://azure.github.io/azure-iot-sdk-c/md__home_runner_work_azure_iot_sdk_c_azure_iot_sdk_c_doc_run_end_to_end_tests.html.
