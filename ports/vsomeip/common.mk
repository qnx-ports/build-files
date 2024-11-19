ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

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
CMAKE_BUILD_TYPE ?= Release

#set the following to TRUE if you want to compile the vsomeip tests.
#If you do, make sure to set GTEST_ROOT to point to the google test library sources
GENERATE_TESTS ?= TRUE
TEST_IP_MASTER ?= XXX.XXX.XXX.XXX
TEST_IP_SLAVE ?= XXX.XXX.XXX.XXX

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = vsomeip_all
.PHONY: vsomeip_all

FLAGS   += -g -D_QNX_SOURCE -DBOOST_NO_CXX98_FUNCTION_BASE
LDFLAGS += -Wl,--build-id=md5 -lang-c++ -lsocket

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
             -DGTEST_ROOT=$(GTEST_ROOT) \
             -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_CXX_STANDARD=17 \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=TRUE \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_MODULE_PATH=$(PROJECT_ROOT) \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DINSTALL_INCLUDE_DIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DVSOMEIP_INSTALL_ROUTINGMANAGERD=ON \
             -DDISABLE_DLT=y

ifeq ($(GENERATE_TESTS), TRUE)
CMAKE_ARGS += -DENABLE_SIGNAL_HANDLING=1 \
              -DTEST_IP_MASTER=$(TEST_IP_MASTER) \
              -DTEST_IP_SLAVE=$(TEST_IP_SLAVE)
endif

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 4)

ifndef NO_TARGET_OVERRIDE
vsomeip_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make all $(MAKE_ARGS)
	@cd build && make build_tests $(MAKE_ARGS)

install: vsomeip_all
	@cd build && make install $(MAKE_ARGS)
	@cd build && make build_tests install $(MAKE_ARGS)

clean iclean spotless:
	@rm -fr build

endif
