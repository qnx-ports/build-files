# [![curl logo](https://curl.se/logo/curl-logo.svg)](https://curl.se/)

curl is a command-line tool for transferring data specified with URL syntax.
Learn how to use curl by reading [the
manpage](https://curl.se/docs/manpage.html) or [everything
curl](https://everything.curl.dev/).

libcurl is the library curl is using to do its job. It is readily available to
be used by your software. Read [the libcurl
manpage](https://curl.se/libcurl/c/libcurl.html) to learn how.

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

cd ~/qnx_workspace

# Download and extract curl release
mkdir -p curl
curl -L https://github.com/curl/curl/releases/download/curl-8_10_1/curl-8.10.1.tar.bz2 -o curl/curl-8.10.1.tar.bz2
tar -xjf curl/curl-8.10.1.tar.bz2 -C curl --strip-components=1

# Build curl from build files
cd build-files/ports/curl
SOURCE_ROOT="../../../curl" ./mkrelease.sh
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git
# Download and extract curl release
mkdir -p curl
curl -L https://github.com/curl/curl/releases/download/curl-8_10_1/curl-8.10.1.tar.bz2 -o curl/curl-8.10.1.tar.bz2
tar -xjf curl/curl-8.10.1.tar.bz2 -C curl --strip-components=1

# Source SDP environment
cd ~/qnx_workspace

# Build curl from build files
cd build-files/ports/curl
SOURCE_ROOT="../../../curl" ./mkrelease.sh
```