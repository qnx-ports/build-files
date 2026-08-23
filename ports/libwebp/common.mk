ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

# Install path configuration
LIBWEBP_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))
PREFIX ?= /usr/local

# Build configurations
CMAKE_BUILD_TYPE ?= Release
BUILD_SHARED_LIBS ?= ON

# Override default QNX build targets
ALL_DEPENDENCIES = libwebp_all
.PHONY: libwebp_all

FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -lsocket

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(LIBWEBP_INSTALL_ROOT) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_INSTALL_INCLUDEDIR=$(LIBWEBP_INSTALL_ROOT)/$(PREFIX)/include \
             -DCMAKE_INSTALL_LIBDIR=$(LIBWEBP_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib \
             -DCMAKE_INSTALL_BINDIR=$(LIBWEBP_INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/bin \
             -DCMAKE_SHARED_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_C_FLAGS="$(FLAGS)" \
             -DCMAKE_CXX_FLAGS="$(FLAGS)" \
             -DCMAKE_AR="$(QNX_HOST)/usr/bin/nto$(CPU)-ar" \
             -DCMAKE_RANLIB="$(QNX_HOST)/usr/bin/nto$(CPU)-ranlib" \
             -DBUILD_SHARED_LIBS=$(BUILD_SHARED_LIBS)

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE
libwebp_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install: libwebp_all
	@cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	@rm -fr build

cuninstall uninstall:

endif
