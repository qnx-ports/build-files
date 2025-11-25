Compile the port for QNX

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

**Dependencies** :
# Clone libev
git clone https://github.com/qnx-ports/libev.git

# Build libev
make -C build-files/ports/libev install

# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j4

# Clone amqp-cpp
git clone https://github.com/qnx-ports/AMQP-CPP.git
cd AMQP-CPP
git checkout qnx-v4.3.27
cd ..

# Build amqp-cpp
QNX_PROJECT_ROOT="$(pwd)/AMQP-CPP" make -C build-files/ports/amqp-cpp/  install -j4
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

**Dependencies** :
# Clone libev
git clone https://github.com/qnx-ports/libev.git

# Build libev
make -C build-files/ports/libev install

# Clone libuv
git clone https://github.com/qnx-ports/libuv.git

# Build libuv
make -C build-files/ports/libuv install -j4

# Clone amqp-cpp
git clone https://github.com/qnx-ports/AMQP-CPP.git
cd AMQP-CPP
git checkout qnx-v4.3.27
cd ..

# Build amqp-cpp
QNX_PROJECT_ROOT="$(pwd)/AMQP-CPP" make -C build-files/ports/amqp-cpp/  install -j4

```