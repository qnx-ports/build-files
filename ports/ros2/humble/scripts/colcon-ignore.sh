#!/bin/bash

echo 'Adding COLCON_IGNORE to packages that will not be built for QNX'

echo "Ignoring uncrustify_vendor"
touch src/ament/uncrustify_vendor/COLCON_IGNORE

echo 'Ignoring ignition packages'
touch src/ignition/COLCON_IGNORE

echo "Ignoring iceoryx"
touch src/eclipse-iceoryx/iceoryx/iceoryx_dds/cmake/cpptoml/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/iceoryx_dds/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/iceoryx_meta/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/cmake/googletest/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/cmake/cyclonedds/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/doc/aspice_swe3_4/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/iceoryx_examples/COLCON_IGNORE
touch src/eclipse-iceoryx/iceoryx/tools/introspection/COLCON_IGNORE

echo "Ignoring ros-visualization"
touch src/ros-visualization/COLCON_IGNORE

echo "Ignoring ros_tutorials"
touch src/ros/ros_tutorials/COLCON_IGNORE

echo "Ignoring mimick_vendor"
touch src/ros2/mimick_vendor/COLCON_IGNORE

echo "Ignoring realtime_support"
touch src/ros2/realtime_support/COLCON_IGNORE

echo "Ignoring rviz"
touch src/ros2/rviz/COLCON_IGNORE
