cmake_minimum_required(VERSION 3.5)

project(eigen3)

find_package(ament_cmake REQUIRED)

set(PACKAGE_VERSION "1.0.0")

macro(build_eigen3)

  set(extra_cmake_args)
  
  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()

  list(APPEND extra_cmake_args  -DINCLUDE_INSTALL_DIR=${CMAKE_CURRENT_BINARY_DIR}/eigen3_install/include)
  list(APPEND extra_cmake_args  -DCMAKE_MODULE_PATH=${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/cmake)
    
  include(ExternalProject)
  ExternalProject_Add(eigen3
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG 3.3
    TIMEOUT 600
    CONFIGURE_COMMAND
      mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/build_eigen ${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/build_unsupported
    BUILD_COMMAND
      cd ${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/build_eigen &&
      cmake -Wno-dev ${extra_cmake_args} ../../eigen3/Eigen && make all &&
      cd ${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/build_unsupported &&
      cmake -Wno-dev ${extra_cmake_args} ../../eigen3/unsupported/Eigen && make all
    INSTALL_COMMAND
      cd ${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/build_eigen && make install &&
      cd ${CMAKE_CURRENT_BINARY_DIR}/eigen3-prefix/src/eigen3/build_unsupported && make install
  )

  # The external project will install to the build folder, but we'll install that on make install.
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/eigen3_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}
  )

endmacro()

if (QNX)
  build_eigen3()
else()
  find_package(Eigen3 QUIET)
  if(NOT Eigen3_FOUND)
    build_eigen3()
  endif()
endif()

ament_package()
