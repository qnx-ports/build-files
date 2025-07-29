ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

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

#choose Release or Debug
CMAKE_BUILD_TYPE ?= release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS) -fPIC -O2
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
CFLAGS += -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include -I$(INSTALL_ROOT)/$(PREFIX)/include

# Add choice to build and install tests
BUILD_TESTING ?= OFF
INSTALL_TESTS ?= OFF
STRICT_REALTIME ?= ON

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_C_FLAGS="$(CFLAGS)" \
             -DCMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_PROJECT_INCLUDE="$(PROJECT_ROOT)/project_hooks.cmake" \
             -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_C_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_INSTALL_DATAROOTDIR=$(INSTALL_ROOT)/$(PREFIX)/share \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DSECURITY=ON \
             -DAsio_INCLUDE_DIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DSTRICT_REALTIME=$(STRICT_REALTIME) \
             -DEPROSIMA_BUILD_TESTS=$(BUILD_TESTING)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
$(NAME)_all:
	@mkdir -p build
	@cd build && cmake -G Ninja $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && VERBOSE=1 ninja $(MAKE_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && VERBOSE=1 ninja install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
endif
