ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#where to install snappy:
#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
SNAPPY_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#This prefix path may be exposed to the source code,
#the linker, or package discovery config files (.pc,
#CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

BUILD_TESTING ?= OFF

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = snappy_all
.PHONY: snappy_all

FLAGS   += -g -D_QNX_SOURCE

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(SNAPPY_INSTALL_ROOT) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_INSTALL_BINDIR=$(SNAPPY_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin \
             -DCMAKE_INSTALL_INCLUDEDIR=$(SNAPPY_INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_INSTALL_LIBDIR=$(SNAPPY_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DCMAKE_INSTALL_SBINDIR=$(SNAPPY_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/sbin \
             -DCMAKE_MODULE_PATH=$(PROJECT_ROOT) \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DCXX_LIBTYPE=${CXX_LIBTYPE} \
             -DGCC_VER=${GCC_VER} \
             -DBUILD_TESTING=$(BUILD_TESTING)\
             -DSNAPPY_BUILD_TESTS=$(BUILD_TESTING) \
             -DSNAPPY_BUILD_BENCHMARKS=$(BUILD_TESTING)

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE
snappy_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install: snappy_all
	@cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	@rm -fr build

cuninstall uninstall:

endif
