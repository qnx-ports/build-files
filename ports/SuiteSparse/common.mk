ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=SuiteSparse

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))
PREFIX ?= /usr/local

BUILD_TESTING ?= OFF
CMAKE_BUILD_TYPE ?= Release

ALL_DEPENDENCIES = SuiteSparse_all
.PHONY: SuiteSparse_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5

EXTRA_CMAKE_C_FLAGS += -I$(QNX_TARGET)/usr/local/mpfr/include \
                       -I$(QNX_TARGET)/aarch64/usr/local/include
EXTRA_CMAKE_EXE_LINKER_FLAGS += -L$(QNX_TARGET)/usr/local/mpfr/lib \
                                -L$(QNX_TARGET)/aarch64/usr/local/lib
include $(MKFILES_ROOT)/qtargets.mk

CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

CFLAGS += -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include \
          -I$(INSTALL_ROOT)/$(PREFIX)/include \
          -I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include \
          -I$(QNX_TARGET)/$(PREFIX)/include \
          -isystem $(QNX_TARGET)/usr/include/c++/v1/ \
          -D_QNX_SOURCE \
          -I$(QNX_TARGET)/$(CPUVARDIR)/usr/local/mpfr/include
LDFLAGS += -L$(QNX_TARGET)/$(CPUVARDIR)/usr/local/mpfr/lib

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DBUILD_SHARED_LIBS=OFF \
             -DSUITESPARSE_USE_FORTRAN=OFF \
             -DSUITESPARSE_USE_BLAS=OFF \
             -DBUILD_TESTING=$(BUILD_TESTING) \
             -DEXTRA_CMAKE_C_FLAGS="$(EXTRA_CMAKE_C_FLAGS)" \
             -DEXTRA_CMAKE_EXE_LINKER_FLAGS="$(EXTRA_CMAKE_EXE_LINKER_FLAGS)"
ifndef NO_TARGET_OVERRIDE
SuiteSparse_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: SuiteSparse_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
	rm -rf $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/suitesparse* \
	       $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include/suitesparse
endif

