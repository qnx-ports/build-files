#!/bin/bash

QNX_SDP_VERSION=qnx800

docker run -it \
  --net=host \
  --privileged \
  -v $HOME/.qnx:$HOME/.qnx \
  -v $HOME/$QNX_SDP_VERSION:$HOME/$QNX_SDP_VERSION \
  -v $HOME/qnx_workspace:$HOME/qnx_workspace \
  "$QNX_SDP_VERSION:latest" /bin/bash --rcfile /usr/local/qnx/.qnxbashrc
