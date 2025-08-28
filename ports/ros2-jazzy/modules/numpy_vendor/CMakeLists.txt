cmake_minimum_required(VERSION 3.5)

project(numpy_vendor)

find_package(ament_cmake REQUIRED)

set(PACKAGE_VERSION "1.0.0")

macro(build_numpy)

  set(QNX_CPPFLAGS        "-D_POSIX_THREADS \
                          -Wno-implicit-function-declaration -Wno-stringop-overflow -Wno-unused-but-set-variable \
                          -D_QNX_SOURCE \
                          -I${QNX_TARGET}/usr/include \
                          -I${QNX_TARGET}/usr/include/python${PYTHON_VERSION_QNX} \
                          -I${QNX_TARGET}/${CPUVARDIR}/usr/include \
                          -I${QNX_TARGET}/${CPUVARDIR}/usr/include/python${PYTHON_VERSION_QNX} \
                          -I${QNX_TARGET}/usr/include/${CPUVARDIR}/python${PYTHON_VERSION_QNX}")

  set(EXPORT_PY export CC=${QNX_HOST}/usr/bin/qcc &&
                export CXX=${QNX_HOST}/usr/bin/qcc &&
                export CFLAGS=-Vgcc_nto${CPUVARDIR} &&
                export CPPFLAGS=${QNX_CPPFLAGS} &&
                export CXXFLAGS=-Vgcc_nto${CPUVARDIR} &&
                export LDSHARED=${QNX_HOST}/usr/bin/qcc &&
                export LDFLAGS=-shared &&
                export host_alias=nto${CPUVARDIR} &&
                export AR=${QNX_HOST}/usr/bin/nto${CPU}-ar &&
                export AS=${QNX_HOST}/usr/bin/nto${CPU}-as &&
                export RANLIB=${QNX_HOST}/usr/bin/nto${CPU}-ranlib &&
                export LD_LIBRARY_PATH=${QNX_HOST}/usr/lib:$ENV{LD_LIBRARY_PATH} &&
                export PATH=${QNX_HOST}/usr/lib:${QNX_HOST}/usr/bin:$ENV{PATH} &&
                export BLAS=None &&
                export LAPACK=None &&
                export ATLAS=None &&
                export NPY_DISABLE_SVML=1 &&
                export SETUPTOOLS_USE_DISTUTILS=stdlib 
  )

  include(ExternalProject)
  ExternalProject_Add(numpy
    GIT_REPOSITORY https://github.com/numpy/numpy.git
    GIT_TAG db4f43983cb938f12c311e1f5b7165e270c393b4
    TIMEOUT 600
    PATCH_COMMAND git apply ${CMAKE_CURRENT_SOURCE_DIR}/numpy.patch
    CONFIGURE_COMMAND ""
    BUILD_COMMAND
      cd ${CMAKE_CURRENT_BINARY_DIR}/numpy-prefix/src/numpy &&
      git submodule update --init &&
      ${EXPORT_PY} &&
      python3 setup.py build_ext -lc++ -b${CMAKE_CURRENT_BINARY_DIR}/numpy_install build --build-temp=${CMAKE_CURRENT_BINARY_DIR}/numpy_install_tmp --build-lib=${CMAKE_CURRENT_BINARY_DIR}/numpy_install
    INSTALL_COMMAND ""
  )

  #The external project will install to the build folder, but we'll install that on make install.
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/numpy_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages
  )

  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/numpy-prefix/src/numpy/numpy/core/include
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages/numpy/core
  )

  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/numpy-prefix/src/numpy/numpy/random/include
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages/numpy/random
  )

  execute_process(COMMAND python3 -c "import sys; print(str(sys.version_info.major)+'.'+str(sys.version_info.minor))" OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE pyversion)
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/numpy-prefix/src/numpy/build/src.linux-x86_64-${pyversion}/numpy/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}/usr/lib/python${PYTHON_VERSION_QNX}/site-packages/numpy
  )

endmacro()

find_package(numpy QUIET)
if(NOT numpy_FOUND)
  build_numpy()
endif()

ament_package()
