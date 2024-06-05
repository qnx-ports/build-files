#!/bin/bash

QNX_SDP_VERSION=qnx800

docker build -t $QNX_SDP_VERSION \
  --build-arg USER_NAME="$(id --user --name | awk '{print $1;}')" \
  --build-arg GROUP_NAME="$(id --group --name | awk '{print $1;}')" \
  --build-arg USER_ID="$(id --user | awk '{print $1;}')" \
  --build-arg GROUP_ID="$(id --group | awk '{print $1;}')" \
  --build-arg QNX_SDP_VERSION=$QNX_SDP_VERSION .
