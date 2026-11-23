ifndef QCONFIG
QCONFIG := qconfig.mk
endif
include $(QCONFIG)

QNX_MK_ROOT := $(MKFILES_ROOT)
include $(QNX_MK_ROOT)/qmacros.mk

NAME := liboqs

# Upstream liboqs source, cloned next to build-files by default.
# Set QNX_PROJECT_ROOT (environment or make command line) to use a checkout elsewhere.
QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)

DEST_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))
INSTALL_ROOT := $(DEST_INSTALL_ROOT)

INSTALL_PREFIX ?= usr/local
PREFIX := $(INSTALL_PREFIX)

LIBOQS_BUILD_TYPE ?= Release
CMAKE_BUILD_TYPE := $(LIBOQS_BUILD_TYPE)

ALL_DEPENDENCIES := $(NAME)_port_build
.PHONY: $(NAME)_port_build install check clean iclean spotless distclean

include $(QNX_MK_ROOT)/qtargets.mk

SEARCH_ROOTS := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(DEST_INSTALL_ROOT)/$(CPUVARDIR)
FIND_MODULE_DIRS := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(DEST_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

PORT_C_FLAGS := $(FLAGS) -I$(QNX_TARGET)/$(PREFIX)/include -I$(DEST_INSTALL_ROOT)/$(PREFIX)/include -D_QNX_SOURCE
PORT_LD_FLAGS := -Wl,--build-id=md5

BUILD_SHARED_LIBS ?= OFF

# Liboqs minimal generic C build configuration
LIBOQS_MINIMAL_ALGS := KEM_ml_kem_512;KEM_ml_kem_768;KEM_ml_kem_1024;SIG_ml_dsa_44;SIG_ml_dsa_65;SIG_ml_dsa_87

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE="$(PROJECT_ROOT)/qnx.nto.toolchain.cmake" \
             -DCMAKE_SYSTEM_PROCESSOR="$(CPUVARDIR)" \
             -DCMAKE_C_FLAGS:STRING="$(PORT_C_FLAGS)" \
             -DCMAKE_EXE_LINKER_FLAGS:STRING="$(PORT_LD_FLAGS)" \
             -DCMAKE_CXX_COMPILER_TARGET="gcc_nto$(CPUVARDIR)" \
             -DCMAKE_C_COMPILER_TARGET="gcc_nto$(CPUVARDIR)" \
             -DCMAKE_INSTALL_PREFIX:PATH="$(DEST_INSTALL_ROOT)" \
             -DCMAKE_INSTALL_LIBDIR:PATH="$(CPUVARDIR)/$(INSTALL_PREFIX)/lib" \
             -DCMAKE_INSTALL_BINDIR:PATH="$(CPUVARDIR)/$(INSTALL_PREFIX)/bin" \
             -DCMAKE_INSTALL_INCLUDEDIR:PATH="$(INSTALL_PREFIX)/include" \
             -DCMAKE_FIND_ROOT_PATH:PATH="$(SEARCH_ROOTS)" \
             -DCMAKE_MODULE_PATH:PATH="$(FIND_MODULE_DIRS)" \
             -DCMAKE_BUILD_TYPE="$(CMAKE_BUILD_TYPE)" \
             -DBUILD_SHARED_LIBS="$(BUILD_SHARED_LIBS)" \
             -DOQS_MINIMAL_BUILD="$(LIBOQS_MINIMAL_ALGS)" \
             -DOQS_USE_OPENSSL=OFF \
             -DOQS_DIST_BUILD=OFF \
             -DOQS_OPT_TARGET=generic \
             -DOQS_ENABLE_KEM_ml_kem_512_x86_64=OFF \
             -DOQS_ENABLE_KEM_ml_kem_768_x86_64=OFF \
             -DOQS_ENABLE_KEM_ml_kem_1024_x86_64=OFF \
             -DOQS_ENABLE_KEM_ml_kem_512_aarch64=OFF \
             -DOQS_ENABLE_KEM_ml_kem_768_aarch64=OFF \
             -DOQS_ENABLE_KEM_ml_kem_1024_aarch64=OFF \
             -DOQS_ENABLE_SIG_ml_dsa_44_x86_64=OFF \
             -DOQS_ENABLE_SIG_ml_dsa_65_x86_64=OFF \
             -DOQS_ENABLE_SIG_ml_dsa_87_x86_64=OFF \
             -DOQS_ENABLE_SIG_ml_dsa_44_aarch64=OFF \
             -DOQS_ENABLE_SIG_ml_dsa_65_aarch64=OFF \
             -DOQS_ENABLE_SIG_ml_dsa_87_aarch64=OFF \
             -DOQS_BUILD_ONLY_LIB=OFF

LIBOQS_MAKE_ARGS ?= -j $(firstword $(JLEVEL) $(LIBOQS_JLEVEL) 1)  # JLEVEL=N on the make command line (README)

ifeq ($(NO_TARGET_OVERRIDE),)
$(NAME)_port_build:
	@mkdir -p build-port
	@cd build-port && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build-port && make VERBOSE=1 all $(LIBOQS_MAKE_ARGS)

install check: $(NAME)_port_build
	@cd build-port && make VERBOSE=1 install $(LIBOQS_MAKE_ARGS)

clean:
	@rm -rf build-port

iclean spotless distclean: clean
endif
