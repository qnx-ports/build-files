ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=gdk-pixbuf

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

#choose Release or Debug
MESON_BUILD_TYPE ?= release

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

#Define _QNX_SOURCE 
CFLAGS += -D_QNX_SOURCE
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

GDK_PIXBUF_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

# testing not availiable for gdk-pixbuf when cross-compiling
BUILD_TESTING = OFF

# Use submoduled Meson
MESON := python3 $(QNX_PROJECT_ROOT)/../meson/meson.py
MESON_FLAGS :=  -Dtiff=disabled \
			    -Dgio_sniffing=false \
                --reconfigure \
				--buildtype=$(MESON_BUILD_TYPE) \
                --prefix=$(GDK_PIXBUF_INSTALL_DIR) \
				--cross-file=../qnx_cross.cfg

NINJA_ARGS := -j $(firstword $(JLEVEL) 1)

# Set cross file
qnx_cross.cfg: $(PROJECT_ROOT)/qnx_cross.cfg.in
	cp $(PROJECT_ROOT)/qnx_cross.cfg.in $@
	sed -i "s|QSDP|$(QNX_HOST)|" $@
	sed -i "s|CPU|$(CPU)|" $@
	sed -i "s|INSTALL_DIR|$(GDK_PIXBUF_INSTALL_DIR)|" $@
	sed -i "s|QNX_TARGET_DIR|$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)|" $@

$(NAME)_all: qnx_cross.cfg
	@mkdir -p build
	@cd build && $(MESON) setup $(MESON_FLAGS) . $(QNX_PROJECT_ROOT)
	@cd build && ninja $(NINJA_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && ninja install $(NINJA_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf qnx_cross.cfg
	rm -rf build

uninstall:

