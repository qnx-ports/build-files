#!/bin/bash

# Function for apply a patch
# $1 arg is the directory
# $2 arg is the patch name
qnx_patch () {
    cd $1
    git apply --whitespace=nowarn $QNX_PORTS_ROS2/qnx_patches/$2 > /dev/null
    cd - > /dev/null
}

QNX_PORTS_ROS2=${PWD}

# Apply QNX patches
qnx_patch ./src/eclipse-cyclonedds/cyclonedds cyclonedds.patch
qnx_patch ./src/osrf/osrf_testing_tools_cpp osrf_testing_tools_cpp.patch
qnx_patch ./src/ros2/common_interfaces common_interfaces.patch
qnx_patch ./src/ros2/rosidl_python rosidl_python.patch
qnx_patch ./src/ros2/geometry2 geometry2.patch
qnx_patch ./src/ros2/orocos_kdl_vendor orocos_kdl_vendor.patch
qnx_patch ./src/ros2/rcl_interfaces rcl_interfaces.patch
qnx_patch ./src/ros2/rclpy rclpy.patch
qnx_patch ./src/ros2/rosbag2 rosbag2.patch
qnx_patch ./src/ros2/tinyxml2_vendor tinyxml2_vendor.patch
qnx_patch ./src/ros2/rmw_dds_common rmw_dds_common.patch
qnx_patch ./src/ros2/unique_identifier_msgs unique_identifier_msgs.patch
qnx_patch ./src/ros2/spdlog_vendor spdlog_vendor.patch
qnx_patch ./src/ros2/ros2_tracing ros2_tracing.patch
qnx_patch ./src/ros2/rcutils rcutils.patch
qnx_patch ./src/ros2/rcpputils rcpputils.patch

qnx_patch ./src/eProsima/Fast-CDR fastcdr.patch
qnx_patch ./src/eProsima/Fast-DDS fastrtps.patch

qnx_patch ./src/ros-tooling/libstatistics_collector libstatistics_collector.patch
qnx_patch ./src/ros2/demos demos.patch
qnx_patch ./src/ros2/rmw/rmw rmw.patch
qnx_patch ./src/ros2/rosidl rosidl.patch
qnx_patch ./src/ros2/rosidl_typesupport rosidl_typesupport.patch
qnx_patch ./src/ros2/rosidl_typesupport_fastrtps rosidl_typesupport_fastrtps.patch
qnx_patch ./src/ament/ament_cmake ament_cmake.patch
qnx_patch ./src/ament/google_benchmark_vendor google_benchmark_vendor.patch

# Apply QNX patches for extra packages
if [ -d ./src/ros-perception/vision_opencv ]; then
    qnx_patch ./src/ros-perception/vision_opencv vision_opencv.patch
else
    echo "vision_opencv not installed. Skipping patch."
fi

echo "Packages patched with QNX changes"
