cmake_minimum_required(VERSION 3.5)

project(opencv_vendor)

find_package(ament_cmake REQUIRED)

set(PACKAGE_VERSION "1.0.0")

macro(build_opencv)

  set(extra_cmake_args)
  
  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()
  
  list(APPEND extra_cmake_args "-DBUILD_EXTRAS=OFF")
  list(APPEND extra_cmake_args "-DBUILD_UNIT_TESTS=OFF")
  list(APPEND extra_cmake_args "-DBUILD_SHARED_LIBS=ON")
  list(APPEND extra_cmake_args "-DBUILD_TESTS=OFF")
  list(APPEND extra_cmake_args "-DBUILD_PERF_TESTS=OFF")
  list(APPEND extra_cmake_args "-DWITH_QT=OFF ")
  list(APPEND extra_cmake_args "-DWITH_GTK=OFF")
  list(APPEND extra_cmake_args "-DBUILD_opencv_gapi=OFF")
  list(APPEND extra_cmake_args "-DWITH_JASPER=OFF")
  list(APPEND extra_cmake_args "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} -Wno-int-to-pointer-cast")
  
  if(DEFINED CMAKE_TOOLCHAIN_FILE)
    list(APPEND extra_cmake_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  endif()
  
  include(ExternalProject)
  ExternalProject_Add(opencv
    GIT_REPOSITORY https://github.com/opencv/opencv.git
    GIT_TAG 01b2c5a77ca6dbef3baef24ebc0a5984579231d9
    TIMEOUT 600
    PATCH_COMMAND git apply ${CMAKE_CURRENT_SOURCE_DIR}/opencv.patch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/opencv_install
      ${extra_cmake_args}
      -Wno-dev
  )

  # The external project will install to the build folder, but we'll install that on make install.
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/opencv_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}
  )

endmacro()

find_package(opencv QUIET)
if(NOT opencv_FOUND)
  build_opencv()
endif()

ament_package()
