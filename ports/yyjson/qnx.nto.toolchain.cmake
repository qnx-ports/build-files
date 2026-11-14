# QNX SDP 8.0 cross toolchain; CMAKE_SYSTEM_PROCESSOR (x86_64 or aarch64le) comes from common.mk.
if("$ENV{QNX_HOST}" STREQUAL "" OR "$ENV{QNX_TARGET}" STREQUAL "")
    message(FATAL_ERROR "Source qnxsdp-env.sh first: QNX_HOST and QNX_TARGET are not set")
endif()
set(QNX TRUE)
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_C_COMPILER $ENV{QNX_HOST}/usr/bin/qcc)
set(CMAKE_CXX_COMPILER $ENV{QNX_HOST}/usr/bin/q++)
set(CMAKE_ASM_COMPILER $ENV{QNX_HOST}/usr/bin/qcc)
# binutils are ntox86_64-ar and ntoaarch64-ar: no "le", unlike the -V names
string(REGEX REPLACE "le$" "" NTO_TOOLS "${CMAKE_SYSTEM_PROCESSOR}")
set(CMAKE_AR "$ENV{QNX_HOST}/usr/bin/nto${NTO_TOOLS}-ar" CACHE PATH "archiver")
set(CMAKE_RANLIB "$ENV{QNX_HOST}/usr/bin/nto${NTO_TOOLS}-ranlib" CACHE PATH "ranlib")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR} ${EXTRA_CMAKE_C_FLAGS}" CACHE STRING "c_flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR}_cxx ${EXTRA_CMAKE_CXX_FLAGS}" CACHE STRING "cxx_flags")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR}" CACHE STRING "asm_flags")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "exe_linker_flags")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "so_linker_flags")
set(CMAKE_FIND_ROOT_PATH "$ENV{QNX_TARGET}" "$ENV{QNX_TARGET}/${CMAKE_SYSTEM_PROCESSOR}")
# common.mk's empty rt/dl/pthread archives are in <build>/stubs, outside the SDP. find_library re-roots every
# search path under each root path (CMake 3.22 even an absolute one already inside a root), so the build folder
# is a root and common.mk passes CMAKE_LIBRARY_PATH=/stubs, which finds <build>/stubs/librt.a.
list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_BINARY_DIR}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
