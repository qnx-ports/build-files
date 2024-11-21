ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=ruy

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#This prefix path may be exposed to the source code,
#the linker, or package discovery config files (.pc,
#CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

BUILD_TESTING ?= OFF

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = ruy_all
.PHONY: ruy_all install check clean

include $(MKFILES_ROOT)/qtargets.mk

NTO_NAME=$(CPU)
#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include -Wno-array-bounds

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DNTO_NAME=$(NTO_NAME) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_INSTALL_LIBDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include/ruy \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DBUILD_SHARED_LIBS=1 \
             -DBUILD_TESTING=$(BUILD_TESTING)

ifndef NO_TARGET_OVERRIDE
ruy_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: ruy_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
endif
