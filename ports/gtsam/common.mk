ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=gtsam

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
GTSAM_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

GTSAM_VERSION = .4.1.1

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = GTSAM_all
.PHONY: GTSAM_all install check clean

#Required for 7.0
FLAGS += -D_QNX_SOURCE
CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -lregex

include $(MKFILES_ROOT)/qtargets.mk

GTSAM_ROOT = $(PROJECT_ROOT)/../../../gtsam

ifndef QNX_TARGET_DATASET_DIR
QNX_TARGET_DATASET_DIR= /data/home/root/gtsam/test
endif

ifdef QNX_PROJECT_ROOT
GTSAM_ROOT=$(QNX_PROJECT_ROOT)
endif

# Add the line below
CMAKE_ARGS = -DEPROSIMA_BUILD_TESTS=ON \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=TRUE \
             -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX=$(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/usr \
             -DCMAKE_INSTALL_LIBDIR=$(GTSAM_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib \
             -DINCLUDE_INSTALL_DIR=$(GTSAM_INSTALL_ROOT)/usr/include \
             -DCMAKE_INSTALL_INCLUDEDIR=$(GTSAM_INSTALL_ROOT)/usr/include \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_PREFIX_PATH=$(GTSAM_INSTALL_ROOT) \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DCMAKE_AR=$(QNX_HOST)/usr/bin/nto$(CPU)-ar \
             -DCMAKE_RANLIB=${QNX_HOST}/usr/bin/nto${CPU}-ranlib \
			 -DCPUVARDIR=$(CPUVARDIR) \
             -DQNX_TARGET_DATASET_DIR=$(QNX_TARGET_DATASET_DIR) 

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
GTSAM_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(GTSAM_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: GTSAM_all
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)

clean iclean spotless:
	@rm -rf build
endif
