#!/bin/bash
echo "
******************************************************************
*
*     Welcome to QNX ROS2 Humble development environment
*     -------------------------------------------------------
*
* Default password for user is \"password\".
*
* Export CPU to x86_64 or aarch64 to build for a specific architecture.
* Unset CPU to build for all architectures.
*
* To build ROS2 run the following:
*
*   1- . ./env/bin/activate
*   2- cd ~/ros2_workspace/ros2
*   3- ./qnx/build/scripts/build-ros2.sh
*
******************************************************************
"

# Setup environment variables
echo "QNX Environment variables are set to:"
source $HOME/$QNX_SDP_VERSION/qnxsdp-env.sh
echo ""
