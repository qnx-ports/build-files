# graphene [![Build](https://github.com/qnx-ports/build-files/actions/workflows/graphene.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/graphene.yml)

**NOTE**: QNX ports are only supported from a Linux host operating system

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

# source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh

# Clone graphene
cd ~/qnx_workspace
git clone https://github.com/qnx-ports/graphene.git

# graphene requires Meson for building, clone meson before proceed
git clone https://github.com/mesonbuild/meson.git

# build graphene
QNX_PROJECT_ROOT="$(pwd)/graphene" make -C build-files/ports/graphene/ JLEVEL=4 install
```

# Compile the port for QNX on Ubuntu host
```bash
# Install the following nessary packages
sudo apt install python3 ninja

# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/graphene.git
git clone https://github.com/mesonbuild/meson.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build graphene
QNX_PROJECT_ROOT="$(pwd)/graphene" make -C build-files/ports/graphene/ JLEVEL=4 install
```

# Deploy binaries via SSH
```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/lib/libgraphene* $TARGET_USER@$TARGET_IP_ADDRESS:~/lib
```

If the `~/lib` directory do not exist, create them with:
```bash
ssh $TARGET_USER@$TARGET_IP_ADDRESS "mkdir -p ~/lib"
````

# Tests
Tests are avaliable, but you have to manually deploy them to your target system. Before running tests, make sure you have deployed all binaries mentioned above.
Currently all tests are passed on both QNX8.0 and 7.1.

```bash
#Set your target's IP here
TARGET_IP_ADDRESS=<target-ip-address-or-hostname>
TARGET_USER=<target-username>

scp -r ~/qnx800/target/qnx/aarch64le/usr/local/libexec/installed-tests/graphene-1.0 $TARGET_USER@$TARGET_IP_ADDRESS:~
```
Tests should be avaliable in `~/graphene-1.0` on your target system. Execute commands below to run all tests, result will be stored in ./test.result and output to the terminal as well.
```bash
#ssh to your target system
ssh $TARGET_USER@$TARGET_IP_ADDRESS

# enter the test directory
cd ~/graphene-1.0

# run all tests
> ./test.result
for test in $(find ./ -type f -not -name 'test.result') ; do
    chmod +x $test
    $test | tee -a ./test.result
done
```
