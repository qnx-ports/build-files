# ComputeLibrary for QNX uses CMake for SDP 8.0 and scons for SDP 7.1

ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=ComputeLibrary

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)

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

BUILD_EXAMPLES ?= OFF
BUILD_TESTING ?= OFF
BUILD_SHARED_LIB ?= ON

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

include $(MKFILES_ROOT)/qtargets.mk

# Figure out if it's SDP 7.1.0 or SDP 8.0.0
SDP_VERSION := $(shell cat $(QNX_TARGET)/etc/qversion 2>/dev/null)
ifeq ($(SDP_VERSION),)
    SDP_VERSION := 7.1.0
endif

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

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include -isystem $(QNX_TARGET)/usr/include/c++/v1/ -D_QNX_SOURCE
LDFLAGS += -Wl,--build-id=md5 -lregex

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DARM_COMPUTE_BUILD_SHARED_LIB=$(BUILD_SHARED_LIB) \
             -DARM_COMPUTE_ENABLE_OPENMP=OFF \
             -DARM_COMPUTE_BUILD_EXAMPLES=$(BUILD_EXAMPLES) \
             -DARM_COMPUTE_BUILD_TESTING=$(BUILD_TESTING)

SCONS_ARGS = -Q \
             debug=1 \
             arch=armv8a \
             os=qnx \
             standalone=0 \
             opencl=0 \
             openmp=0 \
             validation_tests=1 \
             neon=1 \
             toolchain_prefix=" " \
             cppthreads=1 \
             compiler_prefix="" \
             extra_cxx_flags="-D_QNX_SOURCE=1" \
             Werror=0 \
             reference_openmp=0 \
             build_dir=$(PROJECT_ROOT)/nto-aarch64-le/build \
            -j 12

ifndef NO_TARGET_OVERRIDE
ifeq ($(SDP_VERSION), 8.0.0)
$(NAME)_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && make VERBOSE=1 install all $(MAKE_ARGS)
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/kleidiai
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/src
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/CL
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/stb
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/libnpy
	@rm -f $(INSTALL_ROOT)/$(PREFIX)/include/BUILD.bazel
	@rm -f $(INSTALL_ROOT)/$(PREFIX)/include/REUSE.toml
	@echo Done.
else
$(NAME)_all:
	@cd $(QNX_PROJECT_ROOT) && scons $(SCONS_ARGS)

install check: $(NAME)_all
	@echo "Installing..."
	@mkdir -p $(INSTALL_ROOT)/$(PREFIX)/include
	@mkdir -p $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib
	@mkdir -p $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/ComputeLibrary_tests

	@cp -r $(QNX_PROJECT_ROOT)/arm_compute $(INSTALL_ROOT)/$(PREFIX)/include/
	@cp -r $(QNX_PROJECT_ROOT)/support $(INSTALL_ROOT)/$(PREFIX)/include/
	@cp -r $(QNX_PROJECT_ROOT)/include/half $(INSTALL_ROOT)/$(PREFIX)/include/
	@cp -r $(QNX_PROJECT_ROOT)/utils $(INSTALL_ROOT)/$(PREFIX)/include/

	@cp $(PROJECT_ROOT)/nto-aarch64-le/build/*.so* $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/ || true
	@cp $(PROJECT_ROOT)/nto-aarch64-le/build/*.a $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/ || true
	@cp $(PROJECT_ROOT)/nto-aarch64-le/build/tests/arm_compute_* $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/ComputeLibrary_tests
	@echo Done.
endif
endif

clean iclean spotless:
	rm -rf build

uninstall: clean
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/arm_compute
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/support
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/utils
	@rm -rf $(INSTALL_ROOT)/$(PREFIX)/include/half
	@rm -rf $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/libarm_compute*
	@rm -rf $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/ArmCompute
	@rm -rf $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/ComputeLibrary_tests
