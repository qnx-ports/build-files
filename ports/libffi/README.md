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

# Clone libffi
cd ~/qnx_workspace
git clone https://github.com/libffi/libffi.git

# Checkout the latest tag
cd libffi
git checkout v3.4.6

# Run autogen script
./autogen.sh

# Build for either 7.1 or 8.0

# Build libffi on 7.1 for aarch64le and x86_64
source ~/qnx710/qnxsdp-env.sh
./configure --host=aarch64-unknown-nto-qnx7.1.0 --target=aarch64-unknown-nto-qnx7.1.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/aarch64le/usr
./configure --host=x86_64-pc-nto-qnx7.1.0 --target=x86_64-pc-nto-qnx7.1.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/x86_64/usr
make install -j4

# Build libffi on 8.0 for aarch64le and x86_64
source ~/qnx800/qnxsdp-env.sh
./configure --host=aarch64-unknown-nto-qnx8.0.0 --target=aarch64-unknown-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/aarch64le/usr
./configure --host=x86_64-pc-nto-qnx8.0.0 --target=x86_64-pc-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/x86_64/usr
make install -j4

```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace

# Clone libffi
cd ~/qnx_workspace
git clone https://github.com/libffi/libffi.git

# Checkout the latest tag
cd libffi
git checkout v3.4.6

# Run autogen script
./autogen.sh

# Build for either 7.1 or 8.0

# Build libffi on 7.1 for aarch64le and x86_64
source ~/qnx710/qnxsdp-env.sh
./configure --host=aarch64-unknown-nto-qnx7.1.0 --target=aarch64-unknown-nto-qnx7.1.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/aarch64le/usr
./configure --host=x86_64-pc-nto-qnx7.1.0 --target=x86_64-pc-nto-qnx7.1.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/x86_64/usr
make install -j4

# Build libffi on 8.0 for aarch64le and x86_64
source ~/qnx800/qnxsdp-env.sh
./configure --host=aarch64-unknown-nto-qnx8.0.0 --target=aarch64-unknown-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/aarch64le/usr
./configure --host=x86_64-pc-nto-qnx8.0.0 --target=x86_64-pc-nto-qnx8.0.0 --prefix=$QNX_TARGET/usr --exec-prefix=$QNX_TARGET/x86_64/usr
make install -j4
```
