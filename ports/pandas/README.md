# Compile the port for QNX

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

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone numpy
git clone https://github.com/qnx-ports/numpy.git && cd numpy
git submodule update --init --recursive
cd -

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4

# Clone pandas
git clone https://github.com/qnx-ports/pandas.git

# Build pandas
QNX_PROJECT_ROOT="$(pwd)/pandas" make -C build-files/ports/pandas INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```

# Compile the port for QNX on Ubuntu Host

```bash
# Clone the repositories
git clone https://github.com/qnx-ports/build-files.git
# pandas depends on numpy
git clone https://github.com/qnx-ports/numpy.git
git clone https://github.com/qnx-ports/pandas.git

# Install python3.11 and gfortran
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common gfortran

# Build numpy
cd numpy
git submodule update --init --recursive
cd -

# Create a python virtual environment and install necessary packages
python3.11 -m venv env
source env/bin/activate
pip install -U pip Cython wheel requests

# source qnxsdp-env.sh
source ~/qnx800/qnxsdp-env.sh

# Build numpy
QNX_PROJECT_ROOT="$(pwd)/numpy" make -C build-files/ports/numpy install -j4

# Build pandas
QNX_PROJECT_ROOT="$(pwd)/pandas" make -C build-files/ports/pandas INSTALL_ROOT_nto=<staging-install-folder> USE_INSTALL_ROOT=true install -j4
```
