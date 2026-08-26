#!/bin/bash

# Set default values for variables
_qnx_workspace=${QNX_WORKSPACE:-${HOME}/qnx_workspace}
_method=${METHOD:-docker}
_docker_rm=" --rm"
_mounts=()

function help {
    echo "docker-create-container.sh [options]"
    echo
    echo "Starts a new docker container for the QNX Ports' build image previously"
    echo "created by running docker-build-qnx-image.sh."
    echo
    echo "Options"
    echo "-h/--help             This help."
    echo "-m/--method <method>  The method (or application) to use to start the"
    echo "                      container."
    echo "                      If not specified defaults to 'docker'."
    echo "--mount-home          Directs docker to mount the user's entire \$HOME"
    echo "                      directory into the container instead of the usual"
    echo "                      minimum mounts."
    echo "                      If not specified only the following paths are mounted"
    echo "                      into the container:"
    echo "                      - \$HOME/.qnx"
    echo "                      - <sdp_path> (see -s/--sdp for details)"
    echo "                      and if it exists:"
    echo "                      - <workspace_path> (see -w/--workspace for details)"
    echo "--norm                Do not delete the container when it exits. Only the last"
    echo "                      --rm/--norm on the command line has an effect."
    echo "                      The default is to delete the container (--rm)"
    echo "--rm                  Delete the container when it exits. Only the last"
    echo "                      --rm/--norm on the command line has an effect."
    echo "                      The default is to delete the container (--rm)"
    echo "-s/--sdp <sdp_path>   Sets the path of the SDP to mount into the container."
    echo "                      The SDP will automatically be source'd into the"
    echo "                      container's shell."
    echo "                      If not specified, the default depends on the environment."
    echo "                      With the following checks done in order:"
    echo "                      - If QNX_SDP exists it is used as the path to the SDP."
    echo "                      - If QNX_TARGET exists it is used to generate a path to"
    echo "                        the SDP it references."
    echo "                      - Otherwise \$HOME/<sdp_version> is used."
    echo "--sdp-version <ver>   The version of the SDP."
    echo "                      If not specified 'qnx800' is used."
    echo "-v/--volume <path>    Additional paths to mount into the container. They are"
    echo "                      mounted at the same location. So if you specify"
    echo "                      '-v /path/to/something' you will find it in the container"
    echo "                      at '/path/to/something'."
    echo "                      May be specified multiple times for multiple additional"
    echo "                      mounts."
    echo "-w/--workspace <path>   Path to the QNX workspace to mount into the container."
    echo "                        If not specified, defaults to \$HOME/qnx_workspace"
}

# Process command line
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        -m|--method)
            _method="$2"
            shift
            ;;
        --mount-home)
            _mount_home=yes
            ;;
        --norm)
            _docker_rm=""
            ;;
        --rm)
            _docker_rm=" --rm"
            ;;
        -s|--sdp)
            _qnx_sdp="$2"
            shift
            ;;
        --sdp-version)
            _qnx_sdp="${HOME}/$2"
            shift
            ;;
        -v|--volume)
            _mounts+=("$2")
            shift
            ;;
        -w|--workspace)
            _qnx_workspace="$2"
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

# If an SDP wasn't explicitly given on the command line,
# try to figure it out from the environment.
if [ -z "$_qnx_sdp" ]; then
    if [ -n "${QNX_SDP}" ]; then
        _qnx_sdp="${QNX_SDP}"
    elif [ -n "$QNX_TARGET" ]; then
        _qnx_sdp=$(realpath "${QNX_TARGET}/../..")
    elif [ -n "${QNX_SDP_VERSION}" ]; then
        _qnx_sdp=${HOME}/${QNX_SDP_VERSION}
    else
        _qnx_sdp=${HOME}/qnx800
    fi
fi

# Set up the mounts
if [ "$_mount_home" == "yes" ]; then
    _mounts+=("$HOME:$HOME")
else
    # Add the default mounts
    _mounts+=(
        "$HOME/.qnx:$HOME/.qnx"
        "$_qnx_sdp:$_qnx_sdp"
    )
    if [ -d "$_qnx_workspace" ]; then
        _mounts+=("$_qnx_workspace:$_qnx_workspace")
    fi
fi

# Make sure the SDP is available
if [ ! -f ${_qnx_sdp}/qnxsdp-env.sh ]; then
    echo "ERROR: The SDP's path '${_qnx_sdp}' is not available."
    echo "       Explicitly set the path via the QNX_SDP environment variable,"
    echo "       or use the '-s/--sdp <path>' command line argument."
    exit 1
fi
echo "Using SDP from: ${_qnx_sdp}."

${_method} run -it \
  --net=host \
  --privileged \
  ${_docker_rm} \
  --env QNX_SDP="$_qnx_sdp" \
  --env QNX_WORKSPACE="$_qnx_workspace" \
  "${_mounts[@]/#/-v}" \
  "qnx-ports-docker:latest" /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
