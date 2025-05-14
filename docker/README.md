# Docker-based Build Environment for QNX

When you're trying to build multiple QNX projects (demo apps, QNX ports, and your own programs), it can be challenging to maintain a perfect development environment with all of the right dependencies available. This open-source Docker-based build environment aims to simplify building projects by helping you to create a clean and consistent build environment on your host.

The Dockerfile creates an Ubuntu container and pre-installs many common dependencies needed for project building. It also mounts your home directory into the container so folders such as your QNX license and SDP installation (`~/.qnx` and `~/qnx800` by default), plus any projects you are building, will be available to the build environment in the container. (If your QNX installation location is customized, you may wish to edit `docker-create-container.sh` to mount a more appropriate directory.)

Feel free to modify the Dockerfile and scripts for your own usage, and please consider contributing suggested changes or issues to this repo for the benefit of others in the community!

## Pre-requisites

Before starting:

1. Install Docker: https://docs.docker.com/engine/install/ubuntu/
2. If on Linux, make sure to complete the post-installation steps: https://docs.docker.com/engine/install/linux-postinstall/

## Example usage

First, clone this repo and build the Docker image:

```bash
$ mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
$ git clone https://github.com/qnx-ports/build-files.git && cd build-files/docker
$ ./docker-build-qnx-image.sh
```

Next, create a container:

```bash
$ ./docker-create-container.sh

******************************************************************
*
*     Welcome to QNX development environment
*     -------------------------------------------------------
*
* Default password for user is "password".
*
******************************************************************

QNX Environment variables are set to:
QNX_HOST=/home/username/qnx800/host/linux/x86_64
QNX_TARGET=/home/username/qnx800/target/qnx
MAKEFLAGS=-I/home/username/qnx800/target/qnx/usr/include

[QNX] (username) ~$
```

> ***Note:*** Please be aware that your user account password inside the Docker container is `password` by default, and not the same as your user account password in your host terminal.

The QNX toolchain is activated for you when the Docker container starts. When you see `[QNX]` in the prompt, you are interacting with the shell in the Docker container.

#### Working with Python virtual environments

If you deactivate a Python virtual environment in the Docker container, the PATH variable may be reset causing the QNX paths to be not found. You can correct this by reactivating the QNX environment script: `source ~/qnx800/qnxsdp-env.sh`.

## Contribute

Have an idea for improvement or find an issue? Please feel free to open a merge request with some suggested changes, or open an Issue for discussion.

# Get support

The community is ready to help with your questions and issues! For any questions, please feel free to:

- Create an Issue or search existing Issues in the Issues section of this repo
- Ask your question with QNX tag on [Stack Overflow](https://stackoverflow.com/questions/tagged/qnx)
- Post to the community on Reddit at [r/qnx](https://www.reddit.com/r/qnx)