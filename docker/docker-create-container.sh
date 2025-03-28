#!/bin/bash

QNX_SDP_VERSION=qnx800

docker create -it --name=qnx-build \
  --platform linux/amd64 \
  --net=host \
  --privileged \
  -v $HOME:/home/$USER/ \
  "$QNX_SDP_VERSION:latest" /bin/bash --rcfile /usr/local/qnx/.qnxbashrc

docker start qnx-build

docker exec -it qnx-build /bin/bash --rcfile /usr/local/qnx/.qnxbashrc