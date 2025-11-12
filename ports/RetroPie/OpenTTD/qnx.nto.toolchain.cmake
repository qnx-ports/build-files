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

set(QNX TRUE)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_C_COMPILER "${QNX_HOST}/usr/bin/qcc")
set(CMAKE_CXX_COMPILER "${QNX_HOST}/usr/bin/q++")
set(CMAKE_ASM_COMPILER "${QNX_HOST}/usr/bin/qcc")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(CMAKE_LINKER "${QNX_HOST}/usr/bin/x86_86-pc-nto-qnx")
else()
    set(CMAKE_LINKER "${QNX_HOST}/usr/bin/aarch64-unknown-nto-qnx")
endif()
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

set(CMAKE_AR "${QNX_HOST}/usr/bin/nto${CPU}-ar${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "archiver")
set(CMAKE_RANLIB "${QNX_HOST}/usr/bin/nto${CPU}-ranlib${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "ranlib")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR} -std=c++17 ${EXTRA_CMAKE_C_FLAGS}" CACHE STRING "c_flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR}_cxx -std=c++17 ${EXTRA_CMAKE_CXX_FLAGS}" CACHE STRING "cxx_flags")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR} -std=c++17 ${EXTRA_CMAKE_ASM_FLAGS}" CACHE STRING "asm_flags")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR}_cxx -std=c++20 ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "exe_linker_flags")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR}_cxx -std=c++20 ${EXTRA_CMAKE_LINKER_FLAGS}" CACHE STRING "so_linker_flags")
