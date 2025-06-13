LIST=OS CPU VARIANT
ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif
include $(QRDIR)$(QRECURSE)

# A prefix path to use **on the target**. This is
# different from INSTALL_ROOT, which refers to an
# installation destination **on the host machine**.
# This prefix path may be exposed to the source code,
# the linker, or package discovery config files (.pc,
# CMake config modules, etc.). Default is usr
PREFIX = usr/local
PREFIX_EXT = usr

CMAKE_ARGS += -D_gRPC_CARES_INCLUDE_DIR=$(QNX_TARGET)/usr/include
