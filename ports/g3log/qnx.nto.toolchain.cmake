set(QNX TRUE)
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_C_COMPILER qcc)
set(CMAKE_CXX_COMPILER q++)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(G3LOG_DISABLE_BACKTRACE ON CACHE BOOL "Disable backtrace on QNX")
if(QNX)
    add_compile_definitions(QNX_PLATFORM)
endif()

set(QNX_PLATFORM TRUE CACHE BOOL "Building for QNX platform")
if(CMAKE_SYSTEM_NAME STREQUAL "QNX")
    message(STATUS "QNX detected: removing pthread from link flags")
    set(THREADS_PREFER_PTHREAD_FLAG OFF)
    set(PLATFORM_LINK_LIBRARIES regex) # or regex m if math is used
    set(IS_QNX TRUE)
endif()




