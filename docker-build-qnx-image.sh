#!/bin/bash

QNX_SDP_VERSION=qnx800

docker build -t $QNX_SDP_VERSION \
  --build-arg USER_NAME=$(id --user --name) \
  --build-arg GROUP_NAME=$(id --group --name) \
  --build-arg USER_ID=$(id --user) \
  --build-arg GROUP_ID=$(id --group) \
  --build-arg QNX_SDP_VERSION=$QNX_SDP_VERSION .
