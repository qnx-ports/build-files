# cJSON [![Build](https://github.com/qnx-ports/build-files/actions/workflows/cJSON.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/cJSON.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

**Pre-requisite**: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Source your SDP
source ~/qnx800/qnxsdp-env.sh

# Clone cJSON
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/cJSON.git

# Build cJSON
QNX_PROJECT_ROOT="$(pwd)/cJSON" make -C build-files/ports/cJSON install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/cJSON.git

# Source your SDP
source ~/qnx800/qnxsdp-env.sh

# Build cJSON
QNX_PROJECT_ROOT="$(pwd)/cJSON" make -C build-files/ports/cJSON install -j4
```

# How to run tests

scp libraries and tests to the target (note, mDNS is configured from
/boot/qnx_config.txt and uses qnxpi.local by default).
```bash
TARGET_HOST=<target-ip-address-or-hostname>

# Move cJSON test binaries to your QNX target
scp -r $QNX_TARGET/aarch64le/usr/local/bin/cJSON_tests qnxuser@$TARGET_HOST:/data/home/qnxuser/bin

# Move required libraries to your QNX target
scp $QNX_TARGET/aarch64le/usr/local/lib/libcjson* qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
scp $QNX_TARGET/aarch64le/usr/local/lib/libunity.so qnxuser@$TARGET_HOST:/data/home/qnxuser/lib
```

**Note**: `cJSON` uses the [unity test API](https://github.com/ThrowTheSwitch/Unity) to run its tests. You would need `libunity.so` on the target only if you plan on running the tests listed below.

Run tests on the target.
```bash
# ssh into the target
ssh qnxuser@$TARGET_HOST

# Run cJSON tests
cd /data/home/qnxuser/bin/cJSON_tests/
chmod +x *
./cJSON_test
./cjson_add
./compare_tests
./minify_tests
./misc_tests
./parse_array
./parse_examples
./parse_hex4
./parse_number
./parse_object
./parse_string
./parse_value
./parse_with_opts
./print_array
./print_number
./print_object
./print_string
./print_value
./readme_examples
```

**Note**: Test `file_test7_should_be_parsed_and_printed` of `parse_examples` currently fails. This is because cJSON's print function checks for equality between two double type variables with `(==)`. Because this equality comparision catches the small difference in the least significant digits of the stored values at the binary level, cJSON prints the value at a higher precision than the parsed value. 
