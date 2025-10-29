ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk

NAME=mame

## Set up user-overridden variables
QNX_PROJECT_ROOT    ?= $(PRODUCT_ROOT)/../../$(NAME)
PREFIX              ?= usr/local

BUILD_TESTING       ?= 0

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

#Setup pkg-config dir
export PKG_CONFIG_PATH=
PKG_CONFIG_LIBDIR_IN = $($(NAME)_INSTALL_DIR)/lib/pkgconfig:$($(NAME)_INSTALL_DIR)/share/pkgconfig
PKG_CONFIG_TARGET_IN = $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig:$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/share/pkgconfig
export PKG_CONFIG_LIBDIR = $(PKG_CONFIG_LIBDIR_IN):$(PKG_CONFIG_TARGET_IN)

## Set up QNX recursive makefile specifics.
.PHONY: $(NAME)_all install clean
ALL_DEPENDENCIES = $(NAME)_all
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

##########Pre-Target Def############
include $(MKFILES_ROOT)/qtargets.mk
##########Post-Target Def###########

TARGETOS=qnx
ARCHOPTS="-D_QNX_SOURCE -DSDL_DISABLE_IMMINTRIN_H -fPIC -Wno-error=format-overflow -Wno-error=alloc-size-larger-than= -Wno-error=parentheses -Wno-error=pointer-arith"
LDOPTS="-Wl,-rpath-link=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib -Wl,-rpath-link=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib"

SDL_INSTALL_ROOT=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

$(NAME)_all:
	@echo ===============
	@echo Building $(NAME)...
	@echo ===============
	@mkdir -p build
	@cd build && \
		BUILDDIR=$(pwd) \
		TESTS=$(BUILD_TESTING) \
		TARGETOS=$(TARGETOS) \
		ARCHOPTS=$(ARCHOPTS) \
		LDOPTS=$(LDOPTS) \
		SDL_INSTALL_ROOT=$(SDL_INSTALL_ROOT) \
		JLEVEL=$(JLEVEL) \
		USE_QTDEBUG=0 \
		NO_USE_XINPUT=1 \
		NO_X11=1 \
		USE_SYSTEM_LIB_ZLIB=1 \
		VERBOSE=1 \
		make -C $(QNX_PROJECT_ROOT) qnx_$(CPU_ALIAS)


install: $(NAME)_all
	@echo Install not yet supported.

clean:
	@rm -rf build
	@make -C $(QNX_PROJECT_ROOT) clean
