# QNX CMakeLists.txt
# Made for cross-compiling libjson with QNX

#--------------------------------------------
# Verify correct version
cmake_minimum_required ( VERSION 3.5 )
project ( libjson )

#--------------------------------------------
# Set up environment variables
set ( MAJOR_VERSION %MAJOR% )
set ( MINOR_VERSION %MINOR% )
set ( MICRO_VERSION %MICRO% )

#--------------------------------------------
# Library
add_library ( json SHARED
    json.c
)
set_target_properties ( json PROPERTIES
    VERSION             ${MAJOR_VERSION}.${MINOR_VERSION}.${MICRO_VERSION}
    SOVERSION           ${MAJOR_VERSION}
)

#-------------------------------------------
# Test Executable
add_executable ( jsonlint
    jsonlint.c
    json.c
)

#-------------------------------------------
# Installation
install (
    TARGETS             json
    DESTINATION         ${CMAKE_INSTALL_LIBDIR}
)
install (
    TARGETS             jsonlint
    DESTINATION         ${CMAKE_INSTALL_BINDIR}/libjson_tests
)
install (
    DIRECTORY           tests/
    DESTINATION         ${CMAKE_INSTALL_BINDIR}/libjson_tests/test
)
install (
    FILES               json.h
    DESTINATION         ${CMAKE_INSTALL_INCLUDEDIR}
)


