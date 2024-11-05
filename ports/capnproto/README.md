# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Before building capnproto and its tests, you might want to first build and install `muslflt`
under the same staging directory. Projects using capnproto on QNX might also want to link to
`muslflt` for consistent math behavior as other platforms. Without `muslflt`, some tests
may fail and you may run into inconsistencies in results compared to other platforms.

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

# Prerequisite: Install muslflt
# Clone muslflt
git clone https://github.com/qnx-ports/muslflt.git
# Build muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ install -j4

# Clone capnproto
git clone https://github.com/qnx-ports/capnproto.git

# Build capnproto
QNX_PROJECT_ROOT="$(pwd)/capnproto" make -C build-files/ports/capnproto/ install -j4
```

# Compile the port for QNX on Ubuntu host
```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
git clone https://github.com/qnx-ports/muslflt.git
git clone https://github.com/qnx-ports/capnproto.git

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Prerequisite: Install muslflt
QNX_PROJECT_ROOT="$(pwd)/muslflt" make -C build-files/ports/muslflt/ install -j4

# Build
QNX_PROJECT_ROOT="$(pwd)/capnproto" make -C build-files/ports/capnproto/ install -j4
```
