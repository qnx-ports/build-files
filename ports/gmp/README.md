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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone gmp
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp

# Build gmp
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp clean 
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone gmp
wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
tar -xvf gmp-6.2.0.tar.xz 
mv gmp-6.2.0 gmp

# Build gmp
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp clean 
QNX_PROJECT_ROOT="$(pwd)/gmp" make -C build-files/ports/gmp install JLEVEL=4
```

