# QNX Platform
set(QNX TRUE)

set(arch gcc_nto${CMAKE_SYSTEM_PROCESSOR})
set(CMAKE_ASM_COMPILER ${QNX_HOST}/usr/bin/qcc -V${arch})
set(CMAKE_C_COMPILER_TARGET ${arch})
set(CMAKE_CXX_COMPILER_TARGET ${arch})

