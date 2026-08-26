ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=rpi_camera_ipa

#where to install rpi_camera_ipa:
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

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = rpi_camera_ipa_all
.PHONY: rpi_camera_ipa_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5

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
CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR=$(CMAKE_SYSTEM_PROCESSOR) \
             -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DBUILD_QNX_CXX_FLAGS="$(FLAGS)" \
             -DBUILD_QNX_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_VERBOSE_MAKEFILE=1 \
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
             -DPROJECT_ROOT="$(QNX_PROJECT_ROOT)"

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 4)

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE
rpi_camera_ipa_all:
	@mkdir -p build
	cd build && cmake $(CMAKE_ARGS) ../../
	cd build && make all $(MAKE_ARGS) VERBOSE=1

install: rpi_camera_ipa_all
	@cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	rm -fr build

cuninstall uninstall:

endif
