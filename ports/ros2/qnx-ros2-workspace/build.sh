#!/bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

if [ ! -d "$QNX_TARGET" ]; then
    echo "QNX_TARGET is not set. Exiting..."
    exit 1
fi

printenv | grep "QNX"

for arch in aarch64 x86_64; do

    if [ "$arch" == "aarch64" ]; then
        CPUVARDIR=aarch64le
        CPUVAR=aarch64le
    elif [ "$arch" == "arm" ]; then
        CPUVARDIR=armle-v7
        CPUVAR=armv7le
    elif [ "${arch}" == "x86_64" ]; then
        CPUVARDIR=x86_64
        CPUVAR=x86_64
    else
        echo "Invalid architecture. Exiting..."
        exit 1
    fi

    echo "CPU set to $CPUVAR"
    echo "CPUVARDIR set to $CPUVARDIR"

    # Set according to where you installed host installation on target
    ROS2_HOST_INSTALLATION_PATH=$QNX_TARGET/$CPUVARDIR/opt/ros/humble
    CMAKE_MODULE_PATH="$PWD/platform/modules"

    if [ -f "$QNX_TARGET/$CPUVARDIR/opt/ros/humble/local_setup.bash" ]; then
	    ROS2_HOST_INSTALLATION_PATH=$QNX_TARGET/$CPUVARDIR/opt/ros/humble
	    CMAKE_MODULE_PATH="$PWD/platform/modules"
	    NUMPY_HEADERS=$QNX_TARGET/$CPUVARDIR/usr/lib/python3.11/site-packages/numpy/core/include
      echo "Found ROS2 Installation in $ROS2_HOST_INSTALLATION_PATH"
    else
	    echo "ROS2 not found in $ROS2_HOST_INSTALLATION_PATH"
	    echo "Searching in $HOME/ros2_humble/install/$CPUVARDIR"
	    if [ -f "$HOME/ros2_humble/install/$CPUVARDIR/local_setup.bash" ]; then
	      ROS2_HOST_INSTALLATION_PATH=$HOME/ros2_humble/install/$CPUVARDIR
	      CMAKE_MODULE_PATH=" "
	      NUMPY_HEADERS=${ROS2_HOST_INSTALLATION_PATH}/usr/lib/python3.11/site-packages/numpy/core/include
	      echo "ROS2 found in $ROS2_HOST_INSTALLATION_PATH"
      else
	      echo "Failed to find ROS2 in expected locations, please set ROS2_HOST_INSTALLATION_PATH"
	      continue
      fi
    fi

    # sourcing the ROS base installation setup script for the target architecture
    # to configure the ROS cross-compilation environment
    . $ROS2_HOST_INSTALLATION_PATH/local_setup.bash

    printenv | grep "ROS"
    printenv | grep "COLCON"

    mkdir -p logs

    export CPUVARDIR=${CPUVARDIR}
    export CPUVAR=${CPUVAR}
    export ARCH=${arch}

    colcon build --merge-install --cmake-force-configure \
        --build-base=$PWD/build/$CPUVARDIR \
        --event-handlers console_direct+ \
        --install-base=$PWD/install/$CPUVARDIR \
        --cmake-args \
            -DCMAKE_VERBOSE_MAKEFILE=ON \
            -DCMAKE_TOOLCHAIN_FILE="$PWD/platform/qnx.nto.toolchain.cmake" \
	    -DBUILD_TESTING:BOOL="OFF" \
            -DCMAKE_BUILD_TYPE="Release" \
            -DCMAKE_MODULE_PATH=$CMAKE_MODULE_PATH \
            -DROS2_HOST_INSTALLATION_PATH=$ROS2_HOST_INSTALLATION_PATH \
	    -DROS_EXTERNAL_DEPS_INSTALL=${QNX_TARGET}/${CPUVARDIR}/opt/ros/humble \
            -Wno-dev --no-warn-unused-cli

    rc=$?
    if [ $rc -eq 0 ]; then
        echo "$arch Success"
    else
        echo "$arch Error: $rc"
        exit $rc
    fi

    echo " "

done

exit 0
