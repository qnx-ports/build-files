cmake_minimum_required(VERSION 3.5)

project(bullet3_vendor)

find_package(ament_cmake REQUIRED)

set(PACKAGE_VERSION "1.0.0")

macro(build_bullet3)

  set(extra_cmake_args)
  
  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()
  
  list(APPEND extra_cmake_args "-DBUILD_PYBULLET=OFF")
  list(APPEND extra_cmake_args "-DUSE_DOUBLE_PRECISION=ON")
  list(APPEND extra_cmake_args "-DBUILD_OPENGL3_DEMOS=OFF")
  list(APPEND extra_cmake_args "-DBUILD_EXTRAS=OFF")
  list(APPEND extra_cmake_args "-DBUILD_UNIT_TESTS=OFF")
  list(APPEND extra_cmake_args "-DBUILD_CPU_DEMOS=OFF")
  list(APPEND extra_cmake_args "-DUSE_GRAPHICAL_BENCHMARK=OFF")
  list(APPEND extra_cmake_args "-DBULLET2_USE_OPEN_MP_MULTITHREADING=OFF")
  list(APPEND extra_cmake_args "-DBUILD_SHARED_LIBS=ON")
  list(APPEND extra_cmake_args "-DBUILD_BULLET2_DEMOS=OFF")

  list(APPEND extra_cmake_args -DCMAKE_CXX_FLAGS="-Wno-ignored-attributes")
  list(APPEND extra_cmake_args -DCMAKE_C_FLAGS="-Wno-ignored-attributes")

  if(DEFINED CMAKE_TOOLCHAIN_FILE)
    list(APPEND extra_cmake_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  endif()
  
  include(ExternalProject)
  ExternalProject_Add(bullet3
    GIT_REPOSITORY https://github.com/bulletphysics/bullet3.git
    GIT_TAG 2.89
    TIMEOUT 600
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/bullet3_install
      ${extra_cmake_args}
      -Wno-dev
  )

  # The external project will install to the build folder, but we'll install that on make install.
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/bullet3_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}
  )

endmacro()

find_package(bullet3 QUIET)
if(NOT bullet3_FOUND)
  build_bullet3()
endif()

ament_package()
