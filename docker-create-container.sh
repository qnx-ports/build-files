#!/bin/bash

QNX_SDP_VERSION=qnx800

docker run -it \
  --net=host \
  --privileged \
  -v $HOME:$HOME \
  "$QNX_SDP_VERSION:latest" /bin/bash
