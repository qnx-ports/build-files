#!/bin/bash

QNX_SDP_VERSION=${QNX_SDP_VERSION:-qnx800}
METHOD=${METHOD:-docker}

if [ ! -d ${HOME}/${QNX_SDP_VERSION} ]; then
    echo "ERROR: The SDP's path ${HOME}/${QNX_SDP_VERSION} is not available."
    exit 1
fi

echo "Using SDP from ${HOME}/${QNX_SDP_VERSION}"

${METHOD} run -it \
  --net=host \
  --privileged \
  -v $HOME/.qnx:$HOME/.qnx \
  -v $HOME/$QNX_SDP_VERSION:$HOME/$QNX_SDP_VERSION \
  -v $HOME/qnx_workspace:$HOME/qnx_workspace \
  "$QNX_SDP_VERSION:latest" /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
