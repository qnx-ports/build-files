ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=sqlite_orm

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
SQLITEORM_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

SQLITEORM_VERSION = .1.9.0

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = sqlite_orm_all
.PHONY: sqlite_orm_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -lsqlite3

include $(MKFILES_ROOT)/qtargets.mk

QNX_PROJECT_ROOT ?= $(PROJECT_ROOT)/../

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(SQLITEORM_INSTALL_ROOT) \
             -DSQLite3_INCLUDE_DIR=$(QNX_TARGET)/usr/include \
             -DSQLite3_LIBRARY=$(QNX_TARGET)/$(CPUVARDIR)/usr/lib/libsqlite3.so \
			 -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS) -isystem ${QNX_TARGET}/usr/include/c++/v1" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_INSTALL_INCLUDEDIR=$(QNX_TARGET)/usr/include \
             -DCMAKE_INSTALL_LIBDIR=$(QNX_TARGET)/$(CPUVARDIR)/usr/lib \
             -DCMAKE_INSTALL_BINDIR=$(QNX_TARGET)/$(CPUVARDIR)/usr/bin \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DCPU=$(CPU)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
sqlite_orm_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: sqlite_orm_all
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)

clean iclean spotless:
	rm -rf build


endif

