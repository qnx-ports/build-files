# QNX CMakeLists.txt
# Made for cross-compiling libjson with QNX

#--------------------------------------------
# Verify correct version
cmake_minimum_required ( VERSION 3.5 )

#--------------------------------------------
# Set up environment variables
set ( MAJOR_VERSION 1 )
set ( MINOR_VERSION 0 )
set ( MICRO_VERSION 0 )

#--------------------------------------------
# Library
add_library ( json SHARED
    json.c
)
set_target_properties ( json PROPERTIES
    VERSION     ${MAJOR_VERSION}.${MINOR_VERSION}.${MICRO_VERSION}
    SOVERSION   ${MAJOR_VERSION}
)

#-------------------------------------------
# Test Executable
add_executable ( jsonlint
    jsonlint.c
)
target_link_libraries ( jsonlint
    PRIVATE     json
)

#-------------------------------------------
# Installation
install (
    TARGETS             json
    LIBRARY DESTINATION lib
)
install (
    TARGETS             jsonlint
    RUNTIME DESTINATION local/libjson_tests
)
install (
    DIRECTORY           tests/
    DESTINATION         local/libjson_tests/test
)
install (
    FILES               json.h
    DESTINATION         include/libjson
)


