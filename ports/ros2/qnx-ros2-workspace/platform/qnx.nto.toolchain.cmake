# QNX toolchain file for building ROS2

if("$ENV{QNX_HOST}" STREQUAL "")
    message(FATAL_ERROR "QNX_HOST environment variable not found. Please set the variable to your host's build tools")
endif()
if("$ENV{QNX_TARGET}" STREQUAL "")
    message(FATAL_ERROR "QNX_TARGET environment variable not found. Please set the variable to the qnx target location")
endif()

set(QNX_HOST "$ENV{QNX_HOST}")
set(QNX_TARGET "$ENV{QNX_TARGET}")
set(QNX_STAGE "$ENV{QNX_STAGE}")

message(STATUS "using QNX_HOST ${QNX_HOST}")
message(STATUS "using QNX_TARGET ${QNX_TARGET}")
message(STATUS "using QNX_STAGE ${QNX_STAGE}")

set(ARCH "$ENV{ARCH}")
set(CPUVAR "$ENV{CPUVAR}")
set(CPUVARDIR "$ENV{CPUVARDIR}")

message(STATUS "using CPUVAR ${CPUVAR}")
message(STATUS "using CPUVARDIR ${CPUVARDIR}")
message(STATUS "using ARCH ${ARCH}")

set(QNX TRUE)
set(CMAKE_SYSTEM_NAME QNX)

set(CMAKE_C_COMPILER ${QNX_HOST}/usr/bin/qcc)
set(CMAKE_CXX_COMPILER ${QNX_HOST}/usr/bin/q++)

set(CMAKE_SYSTEM_PROCESSOR "${CPUVAR}")

set(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES} ${QNX_TARGET}/usr/include)

set(EXTRA_CMAKE_C_FLAGS "${EXTRA_CMAKE_C_FLAGS} -Wl,-rpath-link,${ROS_EXTERNAL_DEPS_INSTALL}/${CPUVARDIR}/usr/lib:${CMAKE_INSTALL_PREFIX}/lib -DTIXML_USE_STL -DOPENCV_NOSTL_TRANSITIONAL -D_QNX_SOURCE -D__USESRCVERSION -Wno-deprecated-declarations -Wno-unused-parameter -Wno-unused-variable -Wno-ignored-attributes -I${ROS_EXTERNAL_DEPS_INSTALL}/${CPUVARDIR}/include/foonathan/memory/detail ")
set(EXTRA_CMAKE_CXX_FLAGS "${EXTRA_CMAKE_C_FLAGS} ${EXTRA_CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++17")


message(STATUS "using -stdlib=libc++")
set(EXTRA_CMAKE_LINKER_FLAGS "-Wl,--build-id=md5,--as-needed -L${ROS_EXTERNAL_DEPS_INSTALL}/lib")

# needs a cpu + variant
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Vgcc_nto${CPUVAR} ${EXTRA_CMAKE_C_FLAGS}" CACHE STRING "c_flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Vgcc_nto${CPUVAR} ${EXTRA_CMAKE_CXX_FLAGS}" CACHE STRING "cxx_flags")

# needs only cpu, ARCH=(CPU only)
if(${ARCH} STREQUAL "arm")
  set(CMAKE_AR "${QNX_HOST}/usr/bin/ntoarmv7-ar${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "archiver")
  set(CMAKE_RANLIB "${QNX_HOST}/usr/bin/ntoarmv7-ranlib${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "ranlib")
  set(CMAKE_STRIP "${QNX_HOST}/usr/bin/ntoarmv7-strip${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "strip")
else()
  set(CMAKE_AR "${QNX_HOST}/usr/bin/nto${ARCH}-ar${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "archiver")
  set(CMAKE_RANLIB "${QNX_HOST}/usr/bin/nto${ARCH}-ranlib${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "ranlib")
  set(CMAKE_STRIP "${QNX_HOST}/usr/bin/nto${ARCH}-strip${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "strip")
endif()

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "exe_linker_flags")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "so_linker_flags")

set(THREADS_PTHREAD_ARG "0" CACHE STRING "Result from TRY_RUN" FORCE)

########################################################################
# Python setup
########################################################################
# the variable below has to be set according to the output of
# sysconfig.get_config_var('SOABI') on the target, which allows python
# extension files to be found.
set(PYTHON_SOABI cpython-311)
# Find host python then override the variables needed for cross-compiling with QNX cross compiled files.
find_package(PythonInterp 3.11 REQUIRED)
set(PYTHON_INCLUDE_DIR ${QNX_TARGET}/usr/include/${CPUVARDIR}/python3.11;${QNX_TARGET}/${CPUVARDIR}/usr/include/python3.11;${QNX_TARGET}/usr/include/python3.11;${QNX_TARGET}/${CPUVARDIR}/usr/lib/python3.11/site-packages/numpy/core/include;${ROS_EXTERNAL_DEPS_INSTALL}/${CPUVARDIR}/usr/lib/python3.11/site-packages/numpy/core/include)
set(PYTHON_INCLUDE_DIRS ${PYTHON_INCLUDE_DIR})
set(PYTHON_LIBRARY ${QNX_TARGET}/${CPUVARDIR}/usr/lib/libpython3.11.so)
set(PYTHON_LIBRARIES ${PYTHON_LIBRARY})
set(PYTHONLIBS_FOUND)
set(PYTHON_MODULE_EXTENSION .cpython-311.so)
set(PYTHON_IS_DEBUG FALSE)

#
# PYTHON_ADD_LIBRARY (<name> [STATIC|SHARED|MODULE] src1 src2 ... srcN)
# It is used to build modules for python.
#
function (python3_add_library name)
  cmake_parse_arguments (PARSE_ARGV 2 PYTHON_ADD_LIBRARY "STATIC;SHARED;MODULE;WITH_SOABI" "" "")

  if (PYTHON_ADD_LIBRARY_STATIC)
    set (type STATIC)
  elseif (PYTHON_ADD_LIBRARY_SHARED)
    set (type SHARED)
  else()
    set (type MODULE)
  endif()
  
  add_library (${name} ${type} ${PYTHON_ADD_LIBRARY_UNPARSED_ARGUMENTS})
  
  include_directories(${PYTHON_INCLUDE_DIR})
  
  get_property (type TARGET ${name} PROPERTY TYPE)

  if (type STREQUAL "MODULE_LIBRARY")
    target_link_libraries (${name} PRIVATE ${PYTHON_LIBRARY})
    # customize library name to follow module name rules
    set_property (TARGET ${name} PROPERTY PREFIX "")
    if (PYTHON_ADD_LIBRARY_WITH_SOABI AND PYTHON_SOABI)
      set_property (TARGET ${name} PROPERTY SUFFIX ".${PYTHON_MODULE_EXTENSION}")
    endif()
  else()
    if (PYTHON_ADD_LIBRARY_WITH_SOABI)
      message (AUTHOR_WARNING "Find${prefix}: Option `WITH_SOABI` is only supported for `MODULE` library type.")
    endif()
    target_link_libraries (${name} PRIVATE ${PYTHON_LIBRARY})
  endif()
endfunction()

#######################################################################
# Workaround to fix Eigen3Config.cmake setting eigen3 include dirs to
# ${QNX_STAGE}/${CPUVARDIR}/usr/include/ instead of ${QNX_STAGE}/usr/include/
# without having to modify any of the files outside the toolchain file
set(Eigen3_INCLUDE_DIRS ${ROS_EXTERNAL_DEPS_INSTALL}/usr/include/eigen3)
set(EIGEN3_FOUND TRUE)
#######################################################################

#######################################################################
# Search paths for dependencies
#######################################################################
# Do not include runtime paths in libraries because they will be
# incorrect since on target they will be different than on host
set(CMAKE_SKIP_RPATH TRUE CACHE BOOL "If set, runtime paths are not added when using shared libraries.")

#######################################################################
# Search strategy
#######################################################################
# Allow search for programs on host, this will allow programs such as
# make, git and patch to be found and used.
# Only look for headers, libs and packages in the search paths provided
# by CMAKE_FIND_ROOT_PATH

set(CMAKE_FIND_ROOT_PATH)
list(APPEND CMAKE_FIND_ROOT_PATH ${CMAKE_INSTALL_PREFIX})
list(APPEND CMAKE_FIND_ROOT_PATH ${QNX_TARGET};${QNX_TARGET}/${CPUVARDIR})

if(ROS2_HOST_INSTALLATION_PATH)
  list(APPEND CMAKE_FIND_ROOT_PATH ${ROS2_HOST_INSTALLATION_PATH})
endif()

set(NDDSHOME $ENV{NDDSHOME})
if(NDDSHOME)
  list(APPEND CMAKE_FIND_ROOT_PATH $ENV{NDDSHOME}) # Connext RTI libraries root directory
endif()

if(ROS_EXTERNAL_DEPS_INSTALL)
  list(APPEND CMAKE_FIND_ROOT_PATH ${ROS_EXTERNAL_DEPS_INSTALL};${ROS_EXTERNAL_DEPS_INSTALL}/${CPUVARDIR})
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

