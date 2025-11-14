#!/bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
start=$(date +%s.%N)

build(){

    if [ "${CPU}" == "aarch64" ]; then
        CPUVARDIR=aarch64le
        CPUVAR=aarch64le
    elif [ "${CPU}" == "x86_64" ]; then
        CPUVARDIR=x86_64
        CPUVAR=x86_64
    else
        echo "Invalid architecture. Exiting..."
        exit 1
    fi

    echo "CPU set to ${CPUVAR}"
    echo "CPUVARDIR set to ${CPUVARDIR}"
    export CPUVARDIR CPUVAR
    export ARCH=${CPU}
    export WORKSPACE=${PWD}
    export INSTALL_BASE=${PWD}/install/${CPUVARDIR}
    export PROJECT_ROOT=${PWD}
    export LC_NUMERIC="en_US.UTF-8"
    export PYTHONPYCACHEPREFIX=/tmp

    rm -rf build/${CPUVARDIR}/foonathan_memory_vendor/
    rm -rf build/${CPUVARDIR}/netifaces_vendor/
    rm -rf build/${CPUVARDIR}/numpy_vendor/
    rm -rf build/${CPUVARDIR}/opencv_vendor/
    rm -rf build/${CPUVARDIR}/yaml_cpp_vendor/

    # Workaround for building ros2 for the first time so that modules can find this path before
    # numpy is installed into the SDP
    mkdir -p ${QNX_TARGET}/${CPUVARDIR}/opt/ros/humble/usr/lib/python3.11/site-packages/numpy/core/include

    colcon build --merge-install --cmake-force-configure \
        --build-base=build/${CPUVARDIR} \
        --install-base=install/${CPUVARDIR} \
        --cmake-args \
            -DCMAKE_TOOLCHAIN_FILE="${PWD}/platform/qnx.nto.toolchain.cmake" \
            -DCMAKE_MODULE_PATH="${PWD}/modules" \
            -DBUILD_TESTING:BOOL="OFF" \
            -DQNX_TESTING=${QNX_TESTING} \
            -DCMAKE_BUILD_TYPE="Release" \
            -DTHIRDPARTY=FORCE \
            --no-warn-unused-cli \
            -DCPU=${CPU} \
            -DEIGEN3_INCLUDE_DIR="${PWD}/install/${CPUVARDIR}/include/eigen3" \

    # Temporary workaround for numpy naming its so's x86_64-linux-gnu.so
    find ./install/${CPUVARDIR} -name "*cpython-*-x86_64-linux-gnu.so" | xargs rename -f "s/-x86_64-linux-gnu//g"
    find ./install/${CPUVARDIR} -name "*cpython-38.so" | xargs rename -f "s/cpython-38.so/cpython-311.so/g"

    cp -f ./scripts/qnxtest.sh install/${CPUVARDIR}

    # Remove build files under test
    if [ "${QNX_TESTING}" == "ON" ]; then
        find ./install/${CPUVARDIR}/test -name "CMakeFiles" -exec rm -rf {} +
        find ./install/${CPUVARDIR}/test -name "*.o" -exec rm -rf {} +
        find ./install/${CPUVARDIR}/test -name "Makefile" -exec rm -rf {} +
        find ./install/${CPUVARDIR}/test -name "*.cmake" -exec rm -rf {} +
        find ./install/${CPUVARDIR}/test -name "*.txt" -exec rm -rf {} +
        find ./install/${CPUVARDIR}/test -name "*.make" -exec rm -rf {} +
        find ./install/${CPUVARDIR}/test -name "ament_*" -exec rm -rf {} +

        # Install googletest
        cp -f ${QNX_TARGET}/${CPUVARDIR}/usr/lib/libgtest* ./install/${CPUVARDIR}/lib
        cp -f ${QNX_TARGET}/${CPUVARDIR}/usr/lib/libgmock* ./install/${CPUVARDIR}/lib
    else
        echo "Test not installed"
    fi

    # Zip and install humble
    mkdir -p ./opt/ros
    cp -r ./install/${CPUVARDIR} ./opt/ros/humble

    # Patch the python version for all scripts generated with ament_python_install_package
    echo "Patching Python scripts..."
    PYTHON3_PATH=$(which python3)

    grep -rinl "\#\!$PYTHON3_PATH" ./opt/ros/humble | xargs -d '\n' sed -i "1 i #!$QNX_PYTHON3_PATH"
    grep -rinl "\#\!$PYTHON3_PATH" ./opt/ros/humble | xargs -d '\n' sed -i '2 d'

    tar -czf ros2_humble.tar.gz ./opt/ros/humble
    cp -r ./opt ${QNX_TARGET}/${CPUVARDIR}
    rm -rf ./opt
    mv ros2_humble.tar.gz ${QNX_TARGET}/${CPUVARDIR}

    echo "ros2_humble.tar.gz is created at ${QNX_TARGET}/${CPUVARDIR}/ros2_humble.tar.gz"
    echo "Done."
}

if [ ! -d "${QNX_TARGET}" ]; then
    echo "QNX_TARGET is not set. Exiting..."
    exit 1
fi

CPUS=("aarch64" "x86_64")
if [ -z "$CPU" ]; then
    for CPU in ${CPUS[@]}; do
        build
    done
elif [ $CPU == "x86_64" ] || [ $CPU == "aarch64" ] ; then
    build
else
    echo "invalid $CPU please set arch to one of the following x86_64 or aarch64 or unset arch to build all platforms"
    exit 1
fi

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`
echo "Build Successful. Build time: $execution_time"
exit 0
