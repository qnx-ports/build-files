cmake_minimum_required(VERSION 3.15)

# Project name and language
project(rpi_camera_ipa
    VERSION 0.5.1
    DESCRIPTION "RPi camera image processing algorithm library"
    LANGUAGES CXX
)

# Collect the sources we want
set(SOURCE_CPP_FILES
    ${PROJECT_ROOT}/src/ipa/libipa/colours.cpp
    ${PROJECT_ROOT}/src/ipa/libipa/pwl.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx219.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx283.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx290.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx296.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx415.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx477.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx519.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_imx708.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_ov5647.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_ov64a40.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_ov7251.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/cam_helper_ov9281.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/cam_helper/md_parser_smia.cpp

    ${PROJECT_ROOT}/src/ipa/rpi/controller/algorithm.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/controller/controller.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/controller/device_status.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/controller/histogram.cpp

    ${PROJECT_ROOT}/src/ipa/rpi/controller/rpi/agc_channel.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/controller/rpi/agc.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/controller/rpi/awb.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/controller/rpi/lux.cpp

    ${PROJECT_ROOT}/src/ipa/rpi/qnx/log_handler.cpp
    ${PROJECT_ROOT}/src/ipa/rpi/qnx/rpi_camera_ipa.cpp

    ${PROJECT_ROOT}/src/libcamera/yaml_parser.cpp
    ${PROJECT_ROOT}/src/libcamera/base/file.cpp
    ${PROJECT_ROOT}/src/libcamera/base/unique_fd.cpp
    ${PROJECT_ROOT}/src/libcamera/base/utils.cpp
)

# Build shared library
add_library(${PROJECT_NAME} SHARED ${SOURCE_CPP_FILES})

# Header directories
target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_ROOT}/src/ipa/rpi/qnx/public/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    PRIVATE
        ${PROJECT_ROOT}/src/ipa/rpi/qnx/public/include
        ${PROJECT_ROOT}/include
        ${PROJECT_ROOT}/src/ipa
        ${PROJECT_ROOT}/src/ipa/rpi
        ${PROJECT_ROOT}/src/ipa/rpi/cam_helper
        ${PROJECT_ROOT}/src/ipa/rpi/controller
        ${PROJECT_ROOT}/src/ipa/rpi/qnx
)

# Add compiler warnings
target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -pedantic -DLIBCAMERA_BASE_PRIVATE)

# Set library version and SOVERSION
set_target_properties(${PROJECT_NAME} PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "${PROJECT_ROOT}/src/ipa/rpi/qnx/public/include/rpi_camera_ipa.h"
)

# Install rules
install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
