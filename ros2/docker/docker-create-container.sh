#!/bin/bash

if [ -z $QNX_SDP_VERSION ]; then
  echo "Set QNX_SDP_VERSION to be qnx800 or qnx710"
  exit 1
fi

docker run -it \
  --net=host \
  --privileged \
  -v ~/.ssh:$HOME/.ssh \
  -v ~/.qnx:$HOME/.qnx \
  -v $HOME/.qnx:$HOME/.qnx \
  -v $HOME/ros2_workspace:$HOME/ros2_workspace \
  "ros2_humble_$QNX_SDP_VERSION:latest" /bin/bash
