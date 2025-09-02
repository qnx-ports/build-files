# aws-c-cal [![Build](https://github.com/qnx-ports/build-files/actions/workflows/aws-c-cal.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/aws-c-cal.yml)

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

# Clone aws-c-cal
git clone https://github.com/awslabs/aws-c-cal.git

# Build aws-c-cal
make -C build-files/ports/aws-c-cal install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/awslabs/aws-c-cal.git

# Source environment
source ~/qnx800/qnxsdp-env.sh

# Build aws-c-cal
make -C build-files/ports/aws-c-cal install -j4
```
