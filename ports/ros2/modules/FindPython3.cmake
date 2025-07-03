execute_process(
  COMMAND which python3
  OUTPUT_VARIABLE PYTHON3_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(Python3_EXECUTABLE "${PYTHON3_PATH}")
set(Python3_INCLUDE_DIR "${QNX_TARGET}/usr/include/python3.11" "${QNX_TARGET}/usr/include/${CPUVARDIR}/python3.11")
set(Python3_LIBRARY "${QNX_TARGET}/${CPUVARDIR}/usr/lib/libpython3.11.so")
set(Python3_VERSION "3.11.7")
set(Python3_FOUND TRUE)

if (NOT TARGET Python3::Interpreter)
  add_executable(Python3::Interpreter IMPORTED GLOBAL)
  set_target_properties(Python3::Interpreter PROPERTIES
    IMPORTED_LOCATION "${Python3_EXECUTABLE}"
  )
endif()

# Define imported target
if (NOT TARGET Python3::Python)
  add_library(Python3::Python UNKNOWN IMPORTED)
  set_target_properties(Python3::Python PROPERTIES
    IMPORTED_LOCATION "${Python3_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${Python3_INCLUDE_DIR}"
  )
endif()

# Export variables for compatibility
set(Python3_INCLUDE_DIRS ${Python3_INCLUDE_DIR})
set(Python3_LIBRARIES ${Python3_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Python3
  REQUIRED_VARS Python3_EXECUTABLE Python3_INCLUDE_DIR Python3_LIBRARY
  VERSION_VAR Python3_VERSION
)

function(Python3_add_library target_name)
  # Default type
  set(lib_type MODULE)

  # Check if first argument after target is a valid type (STATIC/SHARED/MODULE/OBJECT)
  list(GET ARGV 1 maybe_type)
  if (maybe_type MATCHES "^(STATIC|SHARED|MODULE|OBJECT)$")
    set(lib_type ${maybe_type})
    list(REMOVE_AT ARGV 1)  # Remove TYPE
  endif()

  list(REMOVE_AT ARGV 0)  # Remove target_name

  if (ARGV STREQUAL "")
    message(FATAL_ERROR "Python3_add_library(${target_name}): No sources given")
  endif()

  add_library(${target_name} ${lib_type} ${ARGV})
  target_include_directories(${target_name} PRIVATE ${Python3_INCLUDE_DIRS})
  target_link_libraries(${target_name} PRIVATE Python3::Python)
endfunction()

set(NumPy_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/../../build/${CPUVARDIR}/numpy_vendor/numpy-prefix/src/numpy/numpy/core/include")
set(NumPy_FOUND TRUE)
if (NOT TARGET NumPy::NumPy)
  add_library(NumPy::NumPy INTERFACE IMPORTED)
  set_target_properties(NumPy::NumPy PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${NumPy_INCLUDE_DIR}"
  )
endif()

if (NOT TARGET NumPy::NumPy)
add_library(NumPy::NumPy INTERFACE IMPORTED)
set_target_properties(NumPy::NumPy PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${NumPy_INCLUDE_DIR}"
)
endif()

if (NOT TARGET Python3::NumPy)
add_library(Python3::NumPy INTERFACE IMPORTED)
set_target_properties(Python3::NumPy PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${NumPy_INCLUDE_DIR}"
)
endif()

mark_as_advanced(NumPy_INCLUDE_DIR)
