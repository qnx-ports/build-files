ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=iftop
QNX_PROJECT_ROOT ?= $(shell readlink -f $(PROJECT_ROOT)/../../../$(NAME))

#install into stage
QNX_BASE:=$(notdir $(shell readlink -f $(QNX_HOST)/../../../))
INSTALL_ROOT_nto = /usr/local/stage
IFTOP_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))/$(NAME)/$(QNX_BASE)

#PREFIX ?= /usr/local

#choose Release or Debug
CMAKE_BUILD_TYPE ?= RelWithDebInfo
CMAKE_BUILD_TEST ?= OFF

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install clean

CFLAGS += $(FLAGS) -I$(INSTALL_ROOT_$(OS))/$(CPUVARDIR)/$(PREFIX)/include -D_QNX_SOURCE -O3 -fPIC
CXXFLAGS += $(CFLAGS)
LDFLAGS += -lregex

include $(MKFILES_ROOT)/qtargets.mk

#Setup pkg-config dir
export PKG_CONFIG_PATH=
PKG_CONFIG_LIBDIR_IN = $($(NAME)_INSTALL_DIR)/lib/pkgconfig:$($(NAME)_INSTALL_DIR)/share/pkgconfig
PKG_CONFIG_TARGET_IN = $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig:$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/share/pkgconfig:$(INSTALL_ROOT_$(OS))/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig
export PKG_CONFIG_LIBDIR = $(PKG_CONFIG_LIBDIR_IN):$(PKG_CONFIG_TARGET_IN)

#Config toolchain for qnx
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/configure
CONFIGURE_ARGS = --host=$(CPU)-*-$(OS) \
                 --prefix=$(IFTOP_INSTALL_ROOT)/$(PREFIX)/$(CPU) \
                 --exec-prefix=$(IFTOP_INSTALL_ROOT)/$(CPU) \
                 --srcdir=$(QNX_PROJECT_ROOT) 
CONFIGURE_ENVS = CFLAGS="$(CFLAGS)" \
                 CXXFLAGS="$(CXXFLAGS)" \
                 LDFLAGS="$(LDFLAGS)" \
                 CC="qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                 CXX="${QNX_HOST}/usr/bin/q++ -Vgcc_$(OS)$(CPUVARDIR)" \
                 AR="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ar" \
                 AS="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                 RANDLIB="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ranlib" 

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 4)

build/config.status: $(CONFIGURE_CMD)
	@cd $(QNX_PROJECT_ROOT) && autoreconf -ivf
	@mkdir -p build/config
	@cp $(QNX_PROJECT_ROOT)/config/pthread.c build/config/
	cd build && $(CONFIGURE_CMD) $(CONFIGURE_ARGS) $(CONFIGURE_ENVS)

$(NAME)_all: build/config.status
	@cd build && make $(MAKE_ARGS)

TARGET_INSTALL=@cd build && make install $(MAKE_ARGS)
EXTRA_ICLEAN=-rf build
