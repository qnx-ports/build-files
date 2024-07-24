# build-files

Collection of build files for building QNX ports

Recommended: Use Docker to build the ports

The image includes build tools like CMake and automake to ensure a consistent build environment, but it does not
include the QNX SDP itself. `./docker-create-container.sh` assumes the QNX SDP is in your home folder and mounts
your home folder into the container.

Build the Docker image and create a Docker container:
```bash
# Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/
# Remember to let Docker run with root privileges: https://docs.docker.com/engine/install/linux-postinstall/

# Clone build-files
git clone https://gitlab.com/qnx/ports/build-files.git && cd build-files/docker

# Build the Docker image and create a container
./docker-build-qnx-image.sh
./docker-create-container.sh

```
