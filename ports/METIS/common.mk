ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#where to install METIS:
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
ALL_DEPENDENCIES = metis_all
.PHONY: metis_all

IDXWIDTH  = "\#define IDXTYPEWIDTH 32"
REALWIDTH = "\#define REALTYPEWIDTH 32"

FLAGS   += -g -D_QNX_SOURCE
LDFLAGS_GKLIB += -lregex
LDFLAGS_METIS += -lregex -lGKlib

CMAKE_ARGS_GENERIC = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
                     -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
                     -DCMAKE_MODULE_PATH=$(PROJECT_ROOT) \
                     -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
                     -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
                     -DCPUVARDIR=$(CPUVARDIR) \
                     -DGCC_VER=${GCC_VER} \
                     -DBUILD_SHARED_LIBS=ON \

CMAKE_ARGS_GKLIB = -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
                   -DCMAKE_EXTRA_LINER_FLAGS="$(LDFLAGS_GKLIB)"

CMAKE_ARGS_METIS = -DGKLIB_PATH=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
                   -DCMAKE_EXTRA_LINER_FLAGS="$(LDFLAGS_METIS)" \
                   -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
                   -DCMAKE_INSTALL_BINDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin \
                   -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
                   -DCMAKE_INSTALL_LIBDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
                   -DCMAKE_INSTALL_SBINDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/sbin \
                   -DSHARED=TRUE \

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE

gklib_all:
	@mkdir -p build/GKlib
	@cd build/GKlib && cmake $(CMAKE_ARGS_GENERIC) $(CMAKE_ARGS_GKLIB) $(GKLIB_SRC)
	@cd build/GKlib && make VERBOSE=1 all $(MAKE_ARGS)

gklib_install: gklib_all
	@cd build/GKlib && make VERBOSE=1 install $(MAKE_ARGS)

metis_all: gklib_install
	@mkdir -p build
	@mkdir -p $(QNX_PROJECT_ROOT)/build/xinclude
	@echo $(IDXWIDTH) > $(QNX_PROJECT_ROOT)/build/xinclude/metis.h
	@echo $(REALWIDTH) >> $(QNX_PROJECT_ROOT)/build/xinclude/metis.h
	@cat $(QNX_PROJECT_ROOT)/include/metis.h >> $(QNX_PROJECT_ROOT)/build/xinclude/metis.h
	@cp $(QNX_PROJECT_ROOT)/include/CMakeLists.txt $(QNX_PROJECT_ROOT)/build/xinclude
	@cd $(QNX_PROJECT_ROOT)/build/xinclude && cmake $(CMAKE_ARGS_GENERIC) $(CMAKE_ARGS_METIS) $(QNX_PROJECT_ROOT)
	@cd build && cmake $(CMAKE_ARGS_GENERIC) $(CMAKE_ARGS_METIS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install: metis_all
	@cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	@rm -fr build
	@rm -fr $(QNX_PROJECT_ROOT)/build

cuninstall uninstall:

endif
