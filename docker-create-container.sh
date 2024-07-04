#!/bin/bash

QNX_SDP_VERSION=qnx800

USER_NAME="$(id --user --name | awk '{print $1;}')"

# Run welcome.sh only if /usr/local/qnx/welcome.sh, which is only in the QNX Docker container, exists
WELCOME_SCRIPT="if [ -f /usr/local/qnx/welcome.sh ]; then source /usr/local/qnx/welcome.sh; fi"

# Only inject WELCOME_SCRIPT if it does not exist in .bashrc yet
if ! grep -q "source /usr/local/qnx/welcome.sh" /home/$USER_NAME/.bashrc
then
    echo $WELCOME_SCRIPT >> /home/$USER_NAME/.bashrc
fi

docker run -it \
  --net=host \
  --privileged \
  -v $HOME:$HOME \
  "$QNX_SDP_VERSION:latest" /bin/bash
