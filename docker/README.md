# Docker-based Build Environment for QNX

When you're trying to build multiple QNX projects (demo apps, QNX ports, and your own programs), it can be challenging to maintain a perfect development environment with all of the right dependencies available. This open-source Docker-based build environment aims to simplify building projects by helping you to create a clean and consistent build environment on your host.

The Dockerfile creates an Ubuntu container and pre-installs many common dependencies needed for project building. It also mounts the qnx_workspace directory (from your home) into the container, so any projects you are building, will be available to the build environment in the container.
It also adds an SDP installation, so you are ready to go!

Feel free to modify the Dockerfile and scripts for your own usage, and please consider contributing suggested changes or issues to this repo for the benefit of others in the community!

## Pre-requisites

Before starting:

1. Install Docker: https://docs.docker.com/engine/install/ubuntu/
2. If on Linux, make sure to complete the post-installation steps: https://docs.docker.com/engine/install/linux-postinstall/
3. Download QNX Software Center for Linux from myQNX and copy the file into the docker build-files/docker subfolder.
4. Edit the **creds.txt** file and store there your myQNX credentials. This is required for downloading the SDP. After the docker image is ready, you may delete the file. The generated docker image will not include your credentials, however your SDP license will be a part of the image.

## Example usage

First, clone this repo and build the Docker image:

```bash
$ mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
$ git clone https://github.com/qnx-ports/build-files.git && cd build-files/docker
$ ./docker-build-image.sh 8.0.3
```

Next, run a container:

```bash
$ ./docker-run-container.sh

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

#### Non-interactive mode

If can also use the docker image in a non-interactive way, for example to let it compile your project.
Below example with create and run a container based on the docker image for SDP 8.0.3 and build check library for the aarch64 architecture. After the work is done, the container will be automatically deleted.

docker run --rm -it --net=host --privileged -v $HOME/qnx_workspace:$HOME/qnx_workspace qnx_osg:**8.0.3** "source /usr/local/qnx/.qnxbashrc && **CPULIST=aarch64 make** -C build-files/ports/**check**"


#### Working with Python virtual environments

If you deactivate a Python virtual environment in the Docker container, the PATH variable may be reset causing the QNX paths to be not found. You can correct this by reactivating the QNX environment script: `source ~/qnx800/qnxsdp-env.sh`.

## Contribute

Have an idea for improvement or find an issue? Please feel free to open a merge request with some suggested changes, or open an Issue for discussion.

# Get support

The community is ready to help with your questions and issues! For any questions, please feel free to:

- Create an Issue or search existing Issues in the Issues section of this repo
- Ask your question with QNX tag on [Stack Overflow](https://stackoverflow.com/questions/tagged/qnx)
- Post to the community on Reddit at [r/qnx](https://www.reddit.com/r/qnx)