# Docker-based Build Environment for QNX

When you're trying to build multiple QNX projects (demo apps, QNX ports, and your own programs), it can be challenging to maintain a perfect development environment with all of the right dependencies available. This open-source Docker-based build environment aims to simplify building projects by helping you to create a clean and consistent build environment on your host.

The Dockerfile creates an Ubuntu container and pre-installs many common dependencies needed for project building. By default it tries to mount your local SDP and qnx_workspace into the container. If the locations of these are in non-standard locations, you can use either environment variables or command line arguments to explicitly specify them. Please see below for details.

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

## Arguments to docker-create-container

docker-create-container.sh supports the following environment variables and command line arguments to adjust its behaviour. Please note that generally speaking, command line arguments will override environment variables.

### docker-create-container.sh help
docker-create-container.sh [options]

Starts a new docker container for the QNX Ports' build image previously
created by running docker-build-qnx-image.sh.

Options
-h/--help             This help.
-m/--method <method>  The method (or application) to use to start the
                      container.
                      If not specified defaults to 'docker'.
--mount-home          Directs docker to mount the user's entire $HOME
                      directory into the container instead of the usual
                      minimum mounts.
                      If not specified only the following paths are mounted
                      into the container:
                      - $HOME/.qnx
                      - <sdp_path> (see -s/--sdp for details)
                      and if it exists:
                      - <workspace_path> (see -w/--workspace for details)
--norm                Do not delete the container when it exits. Only the last
                      --rm/--norm on the command line has an effect.
                      The default is to delete the container (--rm)
--rm                  Delete the container when it exits. Only the last
                      --rm/--norm on the command line has an effect.
                      The default is to delete the container (--rm)
-s/--sdp <sdp_path>   Sets the path of the SDP to mount into the container.
                      The SDP will automatically be source'd into the
                      container's shell.
                      If not specified, the default depends on the environment.
                      With the following checks done in order:
                      - If QNX_SDP exists it is used as the path to the SDP.
                      - If QNX_TARGET exists it is used to generate a path to
                        the SDP it references.
                      - Otherwise $HOME/<sdp_version> is used.
--sdp-version <ver>   The version of the SDP.
                      If not specified 'qnx800' is used.
-v/--volume <path>    Additional paths to mount into the container. They are
                      mounted at the same location. So if you specify
                      '-v /path/to/something' you will find it in the container
                      at '/path/to/something'.
                      May be specified multiple times for multiple additional
                      mounts.
-w/--workspace <path>   Path to the QNX workspace to mount into the container.
                        If not specified, defaults to $HOME/qnx_workspace

### SDP Location
The SDP location can be explicitly specified via the QNX_SDP environment variable or the -s/--sdp command line argument. If not specified by either, the script will atempt to discover it by first using a QNX build environment sourced into the calling shell (ie: the results of running 'source ~/<sdp_path>/qnxsdp-env.sh') or, if that isn't avaialble, by assuming the location at $HOME/$QNX_SDP_VERSION.

### SDP Version
The SDP version can be explicitly specified either via the QNX_SDP_VERSION environment variable or the --sdp-version command line argument. If not specified by either, it will default to 'qnx800'.

### Mounts
By default, the container will bind mount two directories into the same location within the container:
- $HOME/.qnx
- <sdp_path>
In addition if $HOME/qnx_workspace exists it will also be bind mounted into the container.

This behaviour can be changed in two ways:
1. By using the --mount-home argument, the user's entire $HOME directory will be mounted into the container. The default mounts will be ignored. Additional mounts specified via -v/--volume on the command line will be honoured.

2. Additional mounts can be added via the -v/--volume command line argument.

## Working with Python virtual environments

If you deactivate a Python virtual environment in the Docker container, the PATH variable may be reset causing the QNX paths to be not found. You can correct this by reactivating the QNX environment script: `source ${QNX_SDP}/qnxsdp-env.sh`.

## Contribute

Have an idea for improvement or find an issue? Please feel free to open a merge request with some suggested changes, or open an Issue for discussion.

# Get support

The community is ready to help with your questions and issues! For any questions, please feel free to:

- Create an Issue or search existing Issues in the Issues section of this repo
- Ask your question with QNX tag on [Stack Overflow](https://stackoverflow.com/questions/tagged/qnx)
- Post to the community on Reddit at [r/qnx](https://www.reddit.com/r/qnx)
