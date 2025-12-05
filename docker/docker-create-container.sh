#!/bin/bash

# Process command line
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--method)
            METHOD="$2"
            shift
            ;;
        --mount-home)
            _mount_home=yes
            ;;
        -s|--sdp)
            QNX_SDP="$2"
            shift
            ;;
        --sdp-version)
            QNX_SDP_VERSION="$2"
            shift
            ;;
        -v|--volume)
            MOUNTS+=("$2")
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

# Set defaults if an explicit value wasn't specified.
METHOD=${METHOD:-docker}
QNX_SDP_VERSION=${QNX_SDP_VERSION:-qnx800}
if [ -z "$QNX_SDP" ]; then
    if [ -n "$QNX_TARGET" ]; then
        QNX_SDP=$(realpath "${QNX_TARGET}/../..")
    else
        QNX_SDP=${HOME}/${QNX_SDP_VERSION}
    fi
fi

# Set up the mounts
if [ "$_mount_home" == "yes" ]; then
    MOUNTS+=("$HOME:$HOME")
else
    # Add the default mounts
    MOUNTS+=(
        "$QNX_SDP:$QNX_SDP"
        "$HOME/.qnx:$HOME/.qnx"
        "$HOME/qnx_workspace:$HOME/qnx_workspace"
    )
fi

# Make sure the SDP is available
if [ ! -d ${QNX_SDP} ]; then
    echo "ERROR: The SDP's path ${QNX_SDP} is not available."
    echo "       Explicitly set the path via the QNX_SDP environment variable,"
    echo "       or the '-s/--sdp <path>' command line argument."
    exit 1
fi
echo "Using SDP from ${QNX_SDP} with version ${QNX_SDP_VERSION}."

${METHOD} run -it \
  --net=host \
  --privileged \
  --env QNX_SDP="$QNX_SDP" \
  --env QNX_SDP_VERSION="$QNX_SDP_VERSION" \
  "${MOUNTS[@]/#/-v}" \
  "qnx-ports-docker:latest" /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
