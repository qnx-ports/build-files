ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=pistache

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)

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

MESON_BUILD_TYPE ?= plain

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install clean

include $(MKFILES_ROOT)/qtargets.mk

PROJECT_INSTALL_DIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
MESON := meson
MESON_SETUP_FLAGS := --buildtype=$(MESON_BUILD_TYPE) \
                     --prefix=$(PREFIX) \
                     --cross-file=../qnx_cross.cfg \
                     -DPISTACHE_BUILD_TESTS=true

MESON_COMPILE_FLAGS := -v -j $(firstword $(JLEVEL) 1)

# Set cross file
qnx_cross.cfg: $(PROJECT_ROOT)/qnx_cross.cfg.in
	cp $(PROJECT_ROOT)/qnx_cross.cfg.in $@
	sed -i "s|QSDP|$(QNX_HOST)|" $@
	sed -i "s|CPU|$(CPU)|" $@
	sed -i "s|INSTALL_DIR|$(PROJECT_INSTALL_DIR)|" $@
	sed -i "s|QNX_TARGET_DIR|$(QNX_TARGET)/$(CPUVARDIR)/usr|" $@

ifndef NO_TARGET_OVERRIDE

$(NAME)_all: qnx_cross.cfg
	@mkdir -p build
	@cd build && $(MESON) setup $(MESON_SETUP_FLAGS) $(QNX_PROJECT_ROOT)
	@cd build && $(MESON) compile $(MESON_COMPILE_FLAGS)

install: $(NAME)_all
	@echo Installing...
	@cd build && DESTDIR=$(INSTALL_ROOT)/$(CPUVARDIR) meson install
	@echo Done.

clean:
	rm -rf qnx_cross.cfg
	rm -rf build

endif