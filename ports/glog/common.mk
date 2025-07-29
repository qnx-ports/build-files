ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=glog 

DIST_BASE=$(PRODUCT_ROOT)/../../../gflags

PREFIX ?= /usr/local

ifdef QNX_PROJECT_ROOT
DIST_BASE=$(QNX_PROJECT_ROOT)
endif

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Debug

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = glog_all
.PHONY: glog_all install check clean test

CFLAGS += $(FLAGS)

include $(MKFILES_ROOT)/qtargets.mk

CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
             -DCMAKE_INSTALL_LIBDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DCMAKE_INSTALL_BINDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_DEBUG_POSTFIX="" \
             -Dgflags_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/gflags \
             -DGTest_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/GTest \
             -DBUILD_TESTING=ON 

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
glog_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(DIST_BASE)/
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: glog_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@cp ../run_tests.sh $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin/glog_tests
	@echo Done

clean iclean spotless:
	rm -fr build

uninstall:
endif