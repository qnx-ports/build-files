set(QNX TRUE)
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_ASM_COMPILER ${CMAKE_CURRENT_LIST_DIR}/qcc-wrapper.sh)
set(CMAKE_C_COMPILER ${CMAKE_CURRENT_LIST_DIR}/qcc-wrapper.sh)
set(CMAKE_CXX_COMPILER ${CMAKE_CURRENT_LIST_DIR}/qcc-wrapper.sh)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_QNX_SOURCE")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_QNX_SOURCE")

# The toolchain file may be included multiple times; some runs
# do not have access to ${CMAKE_SYSTEM_PROCESSOR}. We should
# avoid overriding any variables we set to something invalid.
# Since we know that the first run will include a valid variable,
# cache all of these so that they don't get overridden.
set(CMAKE_ASM_COMPILER_TARGET gcc_nto${CMAKE_SYSTEM_PROCESSOR} CACHE STRING "asm_target")
set(CMAKE_C_COMPILER_TARGET gcc_nto${CMAKE_SYSTEM_PROCESSOR} CACHE STRING "c_target")
set(CMAKE_CXX_COMPILER_TARGET gcc_nto${CMAKE_SYSTEM_PROCESSOR} CACHE STRING "cxx_target")
