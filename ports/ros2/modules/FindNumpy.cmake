set(NumPy_INCLUDE_DIR set(Python3_NumPy_INCLUDE_DIRS ${QNX_TARGET}/${CPUVARDIR}/opt/ros/humble/usr/lib/python3.11/site-packages/numpy/core/include))
set(NumPy_FOUND TRUE)
message(FATAL_ERROR hi)
# Create NumPy::NumPy target
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
