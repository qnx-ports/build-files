# QNX toolchain file for building ROS2

if("$ENV{QNX_HOST}" STREQUAL "")
    message(FATAL_ERROR "QNX_HOST environment variable not found. Please set the variable to your host's build tools")
endif()
if("$ENV{QNX_TARGET}" STREQUAL "")
    message(FATAL_ERROR "QNX_TARGET environment variable not found. Please set the variable to the qnx target location")
endif()

set(QNX_HOST "$ENV{QNX_HOST}")
set(QNX_TARGET "$ENV{QNX_TARGET}")

message(STATUS "using QNX_HOST ${QNX_HOST}")
message(STATUS "using QNX_TARGET ${QNX_TARGET}")

set(ARCH "$ENV{ARCH}")
set(CPUVAR "$ENV{CPUVARDIR}")
set(CPUVARDIR "$ENV{CPUVARDIR}")

message(STATUS "using CPUVAR ${CPUVAR}")
message(STATUS "using CPUVARDIR ${CPUVARDIR}")
message(STATUS "using ARCH ${ARCH}")

set(QNX TRUE)
set(CMAKE_SYSTEM_NAME QNX)

set(CMAKE_C_COMPILER ${QNX_HOST}/usr/bin/qcc)
set(CMAKE_CXX_COMPILER ${QNX_HOST}/usr/bin/q++)

set(CMAKE_SYSTEM_PROCESSOR "${CPUVARDIR}")

set(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES} ${QNX_TARGET}/usr/include)

set(EXTRA_CMAKE_C_FLAGS "${EXTRA_CMAKE_C_FLAGS} -Wl,-rpath-link,${QNX_TARGET}/${CPUVARDIR}/usr/lib:${CMAKE_INSTALL_PREFIX}/lib -DOPENCV_NOSTL_TRANSITIONAL -D_QNX_SOURCE")
set(EXTRA_CMAKE_CXX_FLAGS "${EXTRA_CMAKE_C_FLAGS} ${EXTRA_CMAKE_CXX_FLAGS} -Wno-maybe-uninitialized -Wno-invalid-offsetof")

# needs a cpu + variant
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR} ${EXTRA_CMAKE_C_FLAGS}" CACHE STRING "c_flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR} -std=c++14 -DTIXML_USE_STL ${EXTRA_CMAKE_CXX_FLAGS}" CACHE STRING "cxx_flags")

# needs only cpu, ARCH=(CPU only)
set(CMAKE_AR "${QNX_HOST}/usr/bin/nto${ARCH}-ar${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "archiver")
set(CMAKE_RANLIB "${QNX_HOST}/usr/bin/nto${ARCH}-ranlib${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "ranlib")
set(CMAKE_STRIP "${QNX_HOST}/usr/bin/nto${ARCH}-strip${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "strip")

set(EXTRA_CMAKE_LINKER_FLAGS "-lregex -Wl,--build-id=md5,--as-needed ${EXTRA_CMAKE_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "exe_linker_flags")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "so_linker_flags")

set(THREADS_PTHREAD_ARG "0" CACHE STRING "Result from TRY_RUN" FORCE)

########################################################################
# Python setup
########################################################################
# the variable below has to be set according to the output of
# sysconfig.get_config_var('SOABI') on the target, which allows python
# extension files to be found.
if(EXISTS ${QNX_TARGET}/usr/include/python3.11)
  set(PYTHON_VERSION_QNX 3.11)
  set(PYTHON_VERSION_QNX_ABI 311)
else()
  set(PYTHON_VERSION_QNX 3.8)
  set(PYTHON_VERSION_QNX_ABI 38)
endif()
set(PYTHON_SOABI cpython-38)
# find the host python then override the include and library directories to link against the target cross compiled binaries
find_package(PythonInterp ${PYTHON_VERSION_QNX} REQUIRED)
set(NUMPY_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages)
set(PYTHON_INCLUDE_DIR ${QNX_TARGET}/usr/include/${CPUVARDIR}/python${PYTHON_VERSION_QNX};${QNX_TARGET}/${CPUVARDIR}/usr/include/python${PYTHON_VERSION_QNX};${QNX_TARGET}/usr/include/python${PYTHON_VERSION_QNX};${QNX_TARGET}/${CPUVARDIR}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages/numpy/core/include;${ROS_EXTERNAL_DEPS_INSTALL}/${CPUVARDIR}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages/numpy/core/include)
set(PYTHON_INCLUDE_DIRS ${PYTHON_INCLUDE_DIR})
set(PYTHON_LIBRARY ${QNX_TARGET}/${CPUVARDIR}/usr/lib/libpython${PYTHON_VERSION_QNX}.so)
set(PYTHON_LIBRARIES ${PYTHON_LIBRARY})
set(PYTHONLIBS_FOUND)
set(PYTHON_MODULE_EXTENSION .cpython-${PYTHON_VERSION_QNX_ABI}.so)
set(PYTHON_IS_DEBUG FALSE)
#######################################################################
set(Eigen3_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include)
set(EIGEN3_FOUND TRUE)
set(Eigen3_FOUND TRUE)
#######################################################################

#######################################################################
# Search paths for dependencies
#######################################################################
set(CMAKE_FIND_ROOT_PATH ${CMAKE_INSTALL_PREFIX};${QNX_TARGET};${QNX_TARGET}/${CPUVARDIR})

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
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
