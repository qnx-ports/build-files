#!/bin/bash

if [ $# -ne 0 ]; then
  git -C SDP checkout $1
fi

QNX_SDP_VERSION=$(git -C SDP describe --tags)

echo "Using SDP ${QNX_SDP_VERSION}"

docker run -it \
  --net=host \
  --privileged \
  -v $HOME/qnx_workspace:$HOME/qnx_workspace \
  qnx_osg:$QNX_SDP_VERSION
