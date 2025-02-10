ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=libdatrie

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
CFLAGS += -D_QNX_SOURCE -O3 -fPIC
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

$(NAME)_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)


#Config toolchain for qnx
CONFIGURE_CMD = $(QNX_PROJECT_ROOT)/configure
CONFIGURE_ARGS = --host=$(CPU)-*-$(OS) \
                 --prefix=$($(NAME)_INSTALL_DIR) \
                 --srcdir=$(QNX_PROJECT_ROOT)
CONFIGURE_ENVS = CFLAGS="$(CFLAGS)" \
                 CXXFLAGS="$(CXXFLAGS)" \
                 LDFLAGS="$(LDFLAGS)" \
                 CC="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                 CXX="${QNX_HOST}/usr/bin/q++ -Vgcc_$(OS)$(CPUVARDIR)" \
                 AR="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ar" \
                 AS="${QNX_HOST}/usr/bin/qcc -Vgcc_$(OS)$(CPUVARDIR)" \
                 RANDLIB="${QNX_HOST}/usr/bin/$(OS)$(CPU)-ranlib" \


MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

$(NAME)_all:
	@mkdir -p build
	@cd build && $(CONFIGURE_CMD) $(CONFIGURE_ARGS) $(CONFIGURE_ENVS)
	@cd build && make $(MAKE_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && make install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:

