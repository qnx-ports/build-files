set(QNX TRUE)
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_C_COMPILER qcc)
set(CMAKE_CXX_COMPILER q++)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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

if(CMAKE_SYSTEM_NAME STREQUAL "QNX")
    message(STATUS "QNX detected: disabling THREADS_PREFER_PTHREAD_FLAG and removing -pthread from flags")

    # Tell CMake not to add -pthread automatically
    set(THREADS_PREFER_PTHREAD_FLAG OFF)

    # Remove -pthread from C and C++ flags forcibly
    string(REPLACE "-pthread" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    string(REPLACE "-pthread" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()



