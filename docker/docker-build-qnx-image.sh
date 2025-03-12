#!/bin/bash

QNX_SDP_VERSION=qnx800

docker build -t $QNX_SDP_VERSION --platform linux/amd64 \
  --build-arg USER_NAME="$(id -u -n | awk '{print $1;}')" \
  --build-arg GROUP_NAME="$(id -g -n | awk '{print $1;}')" \
  --build-arg USER_ID="$(id -u | awk '{print $1;}')" \
  --build-arg GROUP_ID="$(id -g | awk '{print $1;}')" \
  --build-arg QNX_SDP_VERSION=$QNX_SDP_VERSION .
