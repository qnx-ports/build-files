ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME = OpenBLAS

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

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

ALL_DEPENDENCIES = openblas_all
.PHONY: openblas_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -Wl,--allow-shlib-undefined

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

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS += -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include \
          -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include \
          -Wno-unused -Wno-parentheses -Wno-maybe-uninitialized

# Add choice to build and install tests
BUILD_SHARED_LIBS ?= ON
BUILD_TESTING ?= ON
C_LAPACK ?= ON
OPENBLAS_INSTALL_TESTS ?= ON
USE_OPENMP ?= ON
CPP_THREAD_SAFETY_TEST ?= ON

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR="$(CPUVARDIR)" \
             -DCMAKE_C_FLAGS="$(CFLAGS)" \
             -DCMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DCMAKE_ASM_FLAGS="$(FLAGS)" \
             -DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_SHARED_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DBUILD_SHARED_LIBS=$(BUILD_SHARED_LIBS) \
             -DBUILD_TESTING=$(BUILD_TESTING) \
             -DC_LAPACK=$(C_LAPACK) \
             -DOPENBLAS_INSTALL_TESTS=$(OPENBLAS_INSTALL_TESTS) \
             -DUSE_OPENMP=$(USE_OPENMP) \
             -DCPP_THREAD_SAFETY_TEST=$(CPP_THREAD_SAFETY_TEST) \
             -DTARGET="$(OPENBLAS_TARGET)" \
             -DNOFORTRAN=1\

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
openblas_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: openblas_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	@rm -rf build

uninstall:
endif
