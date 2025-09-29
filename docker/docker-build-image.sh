#!/bin/bash

rm -rf SDP
git clone https://github.com/qnx-ports/SDP.git

if [ $# -ne 0 ]; then
  git -C SDP checkout $1
fi

QNX_SDP_VERSION=$(git -C SDP describe --tags --always)

DOCKER_BUILDKIT=1 docker build --secret id=mycreds,src=creds.txt -t qnx_osg:$QNX_SDP_VERSION \
  --build-arg USER_NAME="$(id --user --name | awk '{print $1;}')" \
  --build-arg GROUP_NAME="$(id --group --name | awk '{print $1;}')" \
  --build-arg USER_ID="$(id --user | awk '{print $1;}')" \
  --build-arg GROUP_ID="$(id --group | awk '{print $1;}')" \
  --build-arg QNX_SDP_VERSION=$QNX_SDP_VERSION .
