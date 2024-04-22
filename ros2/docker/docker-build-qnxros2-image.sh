#!/bin/bash

if [ -z $QNX_TARGET ]; then
  echo "Please source the qnxsdp-env.sh SDP script"
  exit 1
fi

if [ -z $QNX_SDP_VERSION ]; then
  echo "Set QNX_SDP_VERSION to be qnx800 or qnx710"
  exit 1
fi

# Copy SDP into the Docker directory
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

rm -rf $SCRIPTPATH/qnx*

echo "Copying " $QNX_TARGET/../../ " to " $SCRIPTPATH/$QNX_SDP_VERSION
cp -r $QNX_TARGET/../../  $SCRIPTPATH/$QNX_SDP_VERSION

docker build -t ros2_humble_$QNX_SDP_VERSION \
  --build-arg USER_NAME=$(id --user --name) \
  --build-arg GROUP_NAME=$(id --group --name) \
  --build-arg USER_ID=$(id --user) \
  --build-arg GROUP_ID=$(id --group) \
  --build-arg QNX_SDP_VERSION=$QNX_SDP_VERSION .
