ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=capnproto

CAPNPROTO_VERSION = 1.0.2

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = capnproto_all
.PHONY: capnproto_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

MAKE_ARGS = -j $(firstword $(JLEVEL) 1)

CMAKE_ARGS = -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
			 -DBUILD_TESTING=OFF 

ifndef NO_TARGET_OVERRIDE
capnproto_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: capnproto_all
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)

clean iclean spotless:
	@rm -rf build
endif

