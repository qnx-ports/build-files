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

# clone ntpsec
git clone https://github.com/qnx-ports/ntpsec.git

# Build ntpsec
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec clean
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec install

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

# clone ntpsec
git clone https://github.com/qnx-ports/ntpsec.git

# Build ntpsec
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec clean
QNX_PROJECT_ROOT="$(pwd)/ntpsec" make -C build-files/ports/NTPsec install
```
