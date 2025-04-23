ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=bzip2

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

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

#Define _QNX_SOURCE 
CFLAGS += -D_QNX_SOURCE -fPIC -O3
LDFLAGS += -Wl,--build-id=md5 -fPIC

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

#Setup pkg-config dir
export PKG_CONFIG_PATH=
PKG_CONFIG_LIBDIR_IN = $($(NAME)_INSTALL_DIR)/lib/pkgconfig:$($(NAME)_INSTALL_DIR)/share/pkgconfig
PKG_CONFIG_TARGET_IN = $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig:$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/share/pkgconfig
export PKG_CONFIG_LIBDIR = $(PKG_CONFIG_LIBDIR_IN):$(PKG_CONFIG_TARGET_IN)

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1) -C $(QNX_PROJECT_ROOT) \
                                         CC="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                                         AR="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ar" \
                                         RANLIB="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ranlib" \
                                         CFLAGS="$(CFLAGS) -O3" \
                                         LDFLAGS="$(LDFLAGS)"

$(NAME)_all:
	@make clean $(MAKE_ARGS) PREFIX=$($(NAME)_INSTALL_DIR)
	@make bzip2 bzip2recover libbz2.a $(MAKE_ARGS) PREFIX=$($(NAME)_INSTALL_DIR)
	@make -f Makefile-libbz2_so $(MAKE_ARGS) PREFIX=$($(NAME)_INSTALL_DIR)
	@mkdir -p $(INSTALL_ROOT)/$(PREFIX)/include

install check: $(NAME)_all
	@echo Installing...
	@make install bzip2 bzip2recover libbz2.a $(MAKE_ARGS) PREFIX=$($(NAME)_INSTALL_DIR)
	@cd $(QNX_PROJECT_ROOT) && cp libbz2.so.1.0 $($(NAME)_INSTALL_DIR)/lib
	@cd $(QNX_PROJECT_ROOT) && cp libbz2.so.1.0.8 $($(NAME)_INSTALL_DIR)/lib
	@cp $($(NAME)_INSTALL_DIR)/include/bzlib.h $(INSTALL_ROOT)/$(PREFIX)/include
	@cp -r $($(NAME)_INSTALL_DIR)/man $(INSTALL_ROOT)/$(PREFIX)/
	@echo Done.

clean iclean spotless:
	@make clean $(MAKE_ARGS) PREFIX=$($(NAME)_INSTALL_DIR)
	@make clean -f Makefile-libbz2_so $(MAKE_ARGS) PREFIX=$($(NAME)_INSTALL_DIR)
	
uninstall:

