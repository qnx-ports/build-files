# Check if QNX_HOST and QNX_TARGET environment variables are set
if("$ENV{QNX_HOST}" STREQUAL "")
    message(FATAL_ERROR "QNX_HOST environment variable not found. Please set the variable to your host's build tools")
endif()
if("$ENV{QNX_TARGET}" STREQUAL "")
    message(FATAL_ERROR "QNX_TARGET environment variable not found. Please set the variable to the QNX target location")
endif()

# Handle Windows paths if necessary
if(CMAKE_HOST_WIN32)
    set(HOST_EXECUTABLE_SUFFIX ".exe")
    file(TO_CMAKE_PATH "$ENV{QNX_HOST}" QNX_HOST)
    file(TO_CMAKE_PATH "$ENV{QNX_TARGET}" QNX_TARGET)
else()
    set(QNX_HOST "$ENV{QNX_HOST}")
    set(QNX_TARGET "$ENV{QNX_TARGET}")
endif()

message(STATUS "Using QNX_HOST: ${QNX_HOST}")
message(STATUS "Using QNX_TARGET: ${QNX_TARGET}")

set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_SYSTEM_PROCESSOR aarch64le)

if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_PROGRAM)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
endif()
if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_LIBRARY)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
endif()
if (NOT DEFINED CMAKE_FIND_ROOT_PATH_MODE_INCLUDE)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

set(CMAKE_FIND_ROOT_PATH ${TFLITE_EXTERNAL_DEPS_INSTALL};${TFLITE_EXTERNAL_DEPS_INSTALL}/${CPUVARDIR};${QNX_TARGET}/${CPUVARDIR};${CMAKE_INSTALL_PREFIX};${CMAKE_INSTALL_PREFIX}/${CPUVARDIR})

# Specify the compilers
set(CMAKE_C_COMPILER ${QNX_HOST}/usr/bin/qcc)
set(CMAKE_CXX_COMPILER ${QNX_HOST}/usr/bin/q++)
set(CMAKE_ASM_COMPILER ${QNX_HOST}/usr/bin/qcc)



# Set the archiver and ranlib tools
set(CMAKE_AR "${QNX_HOST}/usr/bin/ntoaarch64-ar${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "archiver")
set(CMAKE_RANLIB "${QNX_HOST}/usr/bin/ntoaarch64-ranlib${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "ranlib")

# Set the correct CFLAGS and CXXFLAGS with the correct architecture flag
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Vgcc_ntoaarch64le ${EXTRA_CMAKE_C_FLAGS}" CACHE STRING "C_FLAGS")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Vgcc_ntoaarch64le ${EXTRA_CMAKE_CXX_FLAGS}" CACHE STRING "CXX_FLAGS")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR} ${EXTRA_CMAKE_ASM_FLAGS}" CACHE STRING "ASM_FLAGS")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "exe_linker_flags")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "so_linker_flags")

set(CMAKE_SKIP_RPATH TRUE CACHE BOOL "If set, runtime paths are not added when using shared libraries.")


set(CMAKE_SYSROOT $ENV{QNX_TARGET})
