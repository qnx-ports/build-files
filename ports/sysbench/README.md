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

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone sysbench
git clone https://github.com/qnx-ports/sysbench.git

# Build sysbench
QNX_PROJECT_ROOT="$(pwd)/sysbench" make -C build-files/ports/sysbench clean 
QNX_PROJECT_ROOT="$(pwd)/sysbench" make -C build-files/ports/sysbench install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
# for 7.1
source ~/qnx710/qnxsdp-env.sh
# for 8.0
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# clone sysbench
git clone https://github.com/qnx-ports/sysbench.git

# Build sysbench
QNX_PROJECT_ROOT="$(pwd)/sysbench" make -C build-files/ports/sysbench clean 
QNX_PROJECT_ROOT="$(pwd)/sysbench" make -C build-files/ports/sysbench install JLEVEL=4
```
# Running tests

```bash
export TARGET_HOST=<target-ip-address-or-hostname>
mkdir sysbench

# Copy the dependency libraries for testing
scp $QNX_TARGET/aarch64le/usr/local/bin/sysbench   qnxuser@$TARGET_HOST:~/sysbench
```

### On target run

```bash
cd ~/sysbench
./sysbench cpu run
./sysbench memory run
./sysbench threads run
./sysbench mutex run
./sysbench fileio prepare
./sysbench fileio run
./sysbench fileio cleanup

```
