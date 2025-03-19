ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=graphene

GRAPHENE_VERSION ?= 1.10.8

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

ALL_DEPENDENCIES = graphene_all
.PHONY: graphene_all install check clean

CFLAGS += $(FLAGS)

PREPEND_C_CXXFLAGS := -lgcc_s
PREPEND_C_CXXFLAGS += $(CFLAGS)

include $(MKFILES_ROOT)/qtargets.mk

INSTALL_ROOT_WITH_PREFIX ?= $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)

BUILD_TESTING ?= true

MESON_FLAGS := \
  --buildtype=$(MESON_BUILD_TYPE) \
  --prefix=$(INSTALL_ROOT_WITH_PREFIX) \
  --includedir=$(INSTALL_ROOT)/$(PREFIX) \
  -Dgobject_types=false \
  
MESON := $(QNX_PROJECT_ROOT)/../meson/meson.py

NINJA_ARGS := -j $(firstword $(JLEVEL) 1)

qnx_cross.txt: $(PROJECT_ROOT)/qnx_cross.txt.in
	cp $(PROJECT_ROOT)/qnx_cross.txt.in $@
	sed -i "s|PKG_CONFIG|$(PROJECT_ROOT)/pkg-config-wrapper.sh|" $@
	sed -i "s|QNX_HOST|$(QNX_HOST)|" $@
	sed -i "s|TARGET_ARCH|$(CPU)|" $@
	sed -i "s|CPUDIR|$(CPUVARDIR)|" $@
	sed -i "s|QNX_TARGET_BIN_DIR|$(QNX_TARGET)/$(CPUVARDIR)|" $@
	# PREPEND_C_CXXFLAGS need to be converted to Meson list format
	sed -i "s|PREPEND_C_CXXFLAGS|$(foreach flag,$(PREPEND_C_CXXFLAGS),'$(flag)',)|" $@

graphene_all: qnx_cross.txt
	@mkdir -p build
	@cd build && $(MESON) setup --reconfigure --cross-file=../qnx_cross.txt $(MESON_FLAGS) . $(QNX_PROJECT_ROOT)
	@cd build && ninja $(NINJA_ARGS)

install check: graphene_all
	@echo Installing...
	@cd build && ninja install
	@echo Done.

clean iclean spotless:
	rm -rf build qnx_cross.txt

uninstall: