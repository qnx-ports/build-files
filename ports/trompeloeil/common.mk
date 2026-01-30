ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME = trompeloeil

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../TROMPELOEIL-CPP

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

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

define PINFO
PINFO DESCRIPTION=Header only C++14 mocking framework
endef

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = trompeloeil_all
.PHONY: trompeloeil_all install check clean

include $(MKFILES_ROOT)/qtargets.mk

#Search paths for all of CMake's find_* functions --
#headers, libraries, etc.
#
#$(QNX_TARGET): for architecture-agnostic files shipped with SDP (e.g. headers)
#$(QNX_TARGET)/$(CPUVARDIR): for architecture-specific files in SDP
#$(INSTALL_ROOT)/$(CPUVARDIR): any packages that may have been installed in the staging area
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)

#Path to CMake modules; These are CMake files installed by other packages
#for downstreams to discover them automatically. We support discovering
#CMake-based packages from inside SDP or in the staging area.
#Note that CMake modules can automatically detect the prefix they are
#installed in.
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

# Build with io-pkt changes if we are using io-pkt (even if io-sock is available)
ifeq ($(wildcard $(QNX_TARGET)/$(CPUVARDIR)/lib/libfsnotify.so),)
CFLAGS += -DQNX_IOPKT
endif

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += $(FLAGS) \
          -I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include \
          -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include \
          -I$(INSTALL_ROOT)/$(PREFIX)/include \
          -D_QNX_SOURCE

LDFLAGS += -Wl,--build-id=md5 -lm -lsocket -lang-c++

BUILD_SHARED_LIBS ?= ON

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_C_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DBUILD_SHARED_LIBS=$(BUILD_SHARED_LIBS) \
             -DTROMPELOEIL_BUILD_TESTS=ON

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
trompeloeil_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 self_test thread_terror custom_recursive_mutex $(MAKE_ARGS)

install check: trompeloeil_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build
endif
