ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)

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

MESON_BUILD_TYPE ?= debug

ALL_DEPENDENCIES = glib_all
.PHONY: glib_all install clean

include $(MKFILES_ROOT)/qtargets.mk

export QNX_TARGET

MESON_FLAGS_GLIB := \
  -Dxattr=false

MESON_FLAGS := \
  --buildtype=$(MESON_BUILD_TYPE) \
  -Dprefix=$(INSTALL_ROOT) \
  $(MESON_FLAGS_GLIB)

# Use submoduled Meson
MESON := $(QNX_PROJECT_ROOT)/../meson/meson.py
# Use system ninja
NINJA := ninja

NINJA_ARGS := -j $(firstword $(JLEVEL) 1)


qnx_cross.ini: $(PROJECT_ROOT)/qnx_cross.ini.in
	cp $(PROJECT_ROOT)/qnx_cross.ini.in $@
	sed -i "s|QNX_HOST|$(QNX_HOST)|" $@
	sed -i "s|TARGET_ARCH|$(CPU)|" $@
	sed -i "s|CPUDIR|$(CPUVARDIR)|" $@
	sed -i "s|QNX_TARGET_BIN_DIR|$(QNX_TARGET)/$(CPUVARDIR)|" $@

glib_all: qnx_cross.ini
	mkdir build && cd build && \
	$(MESON) setup --reconfigure --cross-file=../qnx_cross.ini $(MESON_FLAGS) . $(QNX_PROJECT_ROOT) && \
	$(NINJA) $(NINJA_ARGS)

install: glib_all
	cd build && $(NINJA) $(NINJA_ARGS) install

clean:
	rm -r build
