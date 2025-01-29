# This file needs to be set as CMAKE_PROJECT_INCLUDE, which will load
# the following code at the end of every project() call.
if (QNX)
    # ---- muslflt linkage ----
    # Using find_library here allows libmuslflt to exist anywhere within CMake's search path
    # This includes SDP default paths and INSTALL_ROOT. This allows much more flexibility
    # than setting this option in common.mk
    # Note that the archive version causes errors in libgtsam-cephes, and as such we must use the shared object
    find_library(MUSLFLT NAMES libmuslflt.so)
    if (MUSLFLT)
        message(STATUS "Using libmuslflt for correct floating point conversion behavior on QNX")
        add_link_options(-Wl, "${MUSLFLT}")
    else()
        message(WARNING "libmuslflt not found, tests involving floating point conversion will not pass on QNX")
    endif()
endif()