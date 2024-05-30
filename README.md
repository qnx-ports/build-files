# qnx-ports

Collection of build files for building QNX ports

Recommended: Use Docker to build the ports

Using Docker ensures a consistent build environment.

```bash
# Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/

# Clone qnx-ports
git clone https://gitlab.com/qnx/libs/qnx-ports && cd qnx-ports

# Build the Docker image and create a container
./docker-build-qnx-image.sh
./docker-create-container.sh

```

Your home folder will be mounted to the container.
