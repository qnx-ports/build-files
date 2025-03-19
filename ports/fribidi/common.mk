ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=fribidi

FRIBIDI_VERSION = 2.3.0

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

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -Wl,--allow-shlib-undefined

PREPEND_C_CXXFLAGS := -lgcc_s
PREPEND_C_CXXFLAGS += $(CFLAGS)

include $(MKFILES_ROOT)/qtargets.mk
export INSTALL_ROOT_WITH_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
export QNX_TARGET
export CPUVARDIR

# Add choice to build and install tests
BUILD_TESTING ?= true

MESON_FLAGS := \
  --buildtype=$(MESON_BUILD_TYPE) \
  --prefix=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
  --includedir=$(INSTALL_ROOT)/$(PREFIX)/include \
  -Dtests=$(BUILD_TESTING) \
  -Ddocs=false
  
MESON := $(QNX_PROJECT_ROOT)/../meson/meson.py

NINJA_ARGS := -j $(firstword $(JLEVEL) 1)

qnx_cross.txt: $(PROJECT_ROOT)/qnx_cross.txt.in
	cp $(PROJECT_ROOT)/qnx_cross.txt.in $@
	sed -i "s|QNX_HOST|$(QNX_HOST)|" $@
	sed -i "s|TARGET_ARCH|$(CPU)|" $@
	sed -i "s|CPUDIR|$(CPUVARDIR)|" $@
	sed -i "s|QNX_TARGET_BIN_DIR|$(QNX_TARGET)/$(CPUVARDIR)|" $@
	# PREPEND_C_CXXFLAGS need to be converted to Meson list format
	sed -i "s|PREPEND_C_CXXFLAGS|$(foreach flag,$(PREPEND_C_CXXFLAGS),'$(flag)',)|" $@

ifndef NO_TARGET_OVERRIDE
$(NAME)_all: qnx_cross.txt
	@mkdir -p build
	@cd build && $(MESON) setup --reconfigure --cross-file=../qnx_cross.txt $(MESON_FLAGS) . $(QNX_PROJECT_ROOT)
	@cd build && ninja $(NINJA_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && ninja install
	@echo Done.

clean iclean spotless:
	rm -rf build
	rm -f qnx_cross.txt

uninstall:
endif
