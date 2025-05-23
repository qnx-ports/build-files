ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=Catch2

DIST_BASE=$(PRODUCT_ROOT)/../../$(NAME)

QNX_CTEST_MODULE=$(PRODUCT_ROOT)/$(NAME)/ctest.py
QNX_DECODE_CTEST_MODULE=$(PRODUCT_ROOT)/$(NAME)/decode_ctest.py
QNX_TEST_SCRIPT=$(PRODUCT_ROOT)/$(NAME)/base_testsuite.py

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

ifeq ($(CMAKE_BUILD_TYPE), Debug)
	DEBUG_F := -g
endif

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = catch2_all
.PHONY: catch2_all install check clean

CFLAGS += $(DEBUG_F) $(FLAGS)
LDFLAGS += $(DEBUG_F) -Wl,--build-id=md5

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

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DBUILD_SHARED_LIBS:BOOL=ON

CMAKE_QNX_TEST_ARGS = -DCATCH_ENABLE_WERROR:BOOL=OFF \
                      -DQNX_TEST_SCRIPT=$(QNX_TEST_SCRIPT) \
                      -DQNX_CTEST_MODULE=$(QNX_CTEST_MODULE) \
                      -DQNX_DECODE_CTEST_MODULE=$(QNX_DECODE_CTEST_MODULE)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

catch2_all:
	@mkdir -p build
	@cmake -B build -S $(DIST_BASE) $(CMAKE_ARGS) $(CMAKE_QNX_TEST_ARGS) --preset all-tests
	@cmake --build build $(MAKE_ARGS)

install check: catch2_all
	@cmake --install build

clean iclean spotless:
	@rm -rf build
