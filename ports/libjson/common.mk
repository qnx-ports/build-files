ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=libjson

DIST_BASE=$(PRODUCT_ROOT)/../../../libjson

ifdef QNX_PROJECT_ROOT
DIST_BASE=$(QNX_PROJECT_ROOT)
endif

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
libjson_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#set the following to FALSE if generating .pinfo files is causing problems
GENERATE_PINFO_FILES ?= TRUE

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = all
.PHONY: libjson_all install clean

CFLAGS += $(FLAGS)

include $(MKFILES_ROOT)/qtargets.mk

PREFIX ?= /usr/local

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
             -DCMAKE_INSTALL_LIBDIR=$(libjson_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DCMAKE_INSTALL_BINDIR=$(libjson_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin \
             -DCMAKE_INSTALL_INCLUDEDIR=$(libjson_INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
             -DCPU=$(CPU)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
libjson_all:
	@mkdir -p build
	@cp ../CMakeLists.txt $(QNX_PROJECT_ROOT)/
	@../get-version.sh
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)/
	@cd build && make $(MAKE_ARGS) all

install: libjson_all
	@echo Installing...
	@cd build && make $(MAKE_ARGS) install
	@echo Done Installing.

clean iclean spotless:
	rm -rf build

uninstall:
endif
