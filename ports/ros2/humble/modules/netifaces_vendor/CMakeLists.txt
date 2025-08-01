cmake_minimum_required(VERSION 3.5)

project(netifaces_vendor)

find_package(ament_cmake REQUIRED)

set(PACKAGE_VERSION "1.0.0")

macro(build_netifaces)

  set(QNX_COMPILER_FLAGS  -Vgcc_nto${CMAKE_SYSTEM_PROCESSOR})
  set(QNX_LINKER_FLAGS    "-shared -L${QNX_TARGET}/${CPUVARDIR}/lib:${QNX_TARGET}/${CPUVARDIR}/usr/lib")
  set(QNX_CPPFLAGS        "-I${QNX_TARGET}/usr/include \
                          -I${QNX_TARGET}/usr/include/python3.11 \
                          -I${QNX_TARGET}/${CPUVARDIR}/usr/include \
                          -I${QNX_TARGET}/${CPUVARDIR}/usr/include/python3.11 \
                          -I${QNX_TARGET}/usr/include/${CPUVARDIR}/python3.11")

  set(EXPORT_PY     export CC=${CMAKE_C_COMPILER} &&
                    export CXX=${CMAKE_C_COMPILER} &&
                    export LDSHARED=${CMAKE_C_COMPILER} &&
                    export CFLAGS=${QNX_COMPILER_FLAGS} &&
                    export CPPFLAGS=${QNX_CPPFLAGS} &&
                    export CXXFLAGS=${QNX_COMPILER_FLAGS} &&
                    export LDFLAGS=${QNX_LINKER_FLAGS} &&
                    export host_alias=nto$ENV{CPUVARDIR} &&
                    export LD_LIBRARY_PATH=$ENV{QNX_HOST}/usr/lib:$ENV{LD_LIBRARY_PATH} &&
                    export PATH=$ENV{QNX_HOST}/usr/lib:$ENV{QNX_HOST}/usr/bin:$ENV{PATH}
  )

  set(BUILD_EXT_FLAGS "-b${CMAKE_CURRENT_BINARY_DIR}/netifaces_install")

  include(ExternalProject)
  ExternalProject_Add(netifaces
    GIT_REPOSITORY https://github.com/al45tair/netifaces.git
    GIT_TAG 3e02d91ef0e3eb32e614fe2f6bf8dd80d5099aff
    TIMEOUT 600
    PATCH_COMMAND git apply ${CMAKE_CURRENT_SOURCE_DIR}/netifaces.patch
    CONFIGURE_COMMAND ""
    BUILD_COMMAND
      cd ${CMAKE_CURRENT_BINARY_DIR}/netifaces-prefix/src/netifaces &&
      ${EXPORT_PY} &&
      python3 setup.py build_ext ${BUILD_EXT_FLAGS} build --build-temp=${CMAKE_CURRENT_BINARY_DIR}/netifaces_install_tmp/ --build-lib=${CMAKE_CURRENT_BINARY_DIR}/netifaces_install/ --qnx &&
      find ${CMAKE_CURRENT_BINARY_DIR}/netifaces_install/ -name "*cpython-*-x86_64-linux-gnu.so" | xargs rename -f "s/-x86_64-linux-gnu//g"
    INSTALL_COMMAND ""
  )

  #The external project will install to the build folder, but we'll install that on make install.
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/netifaces_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}/lib/python3.11/site-packages
  )

endmacro()

find_package(netifaces QUIET)
if(NOT netifaces_FOUND)
  build_netifaces()
endif()

ament_package()
