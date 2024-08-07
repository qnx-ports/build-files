ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

# Prevent qtargets.mk from re-including qmacros.mk
define VARIANT_TAG
endef

NAME=gtk4

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

# $(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
# by default, unless it was manually re-routed to
# a staging area by setting both INSTALL_ROOT_nto
# and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))
ifeq ($(INSTALL_ROOT),$(QNX_TARGET))
  # Disallow installing GTK4 directly into SDP. GTK4 is a huge project and will be difficult to clean up
  # In addition, having GTK4 in SDP will also interfere with new builds due to the installed pkg-config files.
  $(error It is UNSUPPORTED to install GTK4 directly into SDP. Please set a staging installation path using INSTALL_ROOT_$(OS) and set USE_INSTALL_ROOT=true.)
endif

# A prefix path to use **on the target**. This is
# different from INSTALL_ROOT, which refers to a
# installation destination **on the host machine**.
# This prefix path may be exposed to the source code,
# the linker, or package discovery config files (.pc,
# CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

MESON_BUILD_TYPE ?= debug

ALL_DEPENDENCIES = gtk4_all
.PHONY: gtk4_all install check clean

include $(MKFILES_ROOT)/qtargets.mk

# Export variables for the pkg-config wrapper script
export INSTALL_ROOT_WITH_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)
export QNX_TARGET
export CPUVARDIR

# Prepended C/CPPFLAGS used in qnx_cross.cfg.in
# -lgcc_s is needed to work around libm linkage errors when -Wl,--allow-shlib-undefined is supplied by Meson
PREPEND_C_CXXFLAGS := -lgcc_s

ifeq ($(USE_IOSOCK),true)
ifeq ($(wildcard $(QNX_TARGET)/$(CPUVARDIR)/io-sock),)
    $(error USE_IOSOCK is defined but io-sock is not found inside SDP. Note that io-sock is already the default network stack since QNX SDP 8.0.0. For SDP 7.1.0 and earlier, please ensure io-sock is downloaded via QSC first.)
endif
    $(info Linking to io-sock libsocket...)
    # On QNX SDP 710, io-sock libraries and headers are located in a subfolder inside $QNX_TARGET.
    # Instead of hacking meson.build of all projects to support that, we can simply prepend flags to prioritize linkage
    # inside the io-sock subfolder(s).
    PREPEND_C_CXXFLAGS += -L$(QNX_TARGET)/$(CPUVARDIR)/io-sock/lib -Wl,--as-needed -lsocket -Wl,--no-as-needed -I$(QNX_TARGET)/usr/include/io-sock
endif

# Meson flags (including passthrough for dependencies via meson wrap)
MESON_FLAGS_GTK4 := \
  -Dintrospection=disabled \
  -Dmedia-gstreamer=disabled \
  -Dbuild-examples=false \
  -Dbuild-tests=false \
  -Dbuild-testsuite=false \
  -Ddemos=true \
  -Dwayland-backend=false \
  -Dx11-backend=false \
  -Dvulkan=disabled \
  -Ddocumentation=false \

MESON_FLAGS_GLIB := \
  -Dglib:xattr=false \
  -Dglib:tests=false \

MESON_FLAGS_GDK_PIXBUF := \
  -Dgdk-pixbuf:gio_sniffing=false \
  -Dgdk-pixbuf:docs=false \
  -Dgdk-pixbuf:man=false \
  -Dgdk-pixbuf:tests=false \

MESON_FLAGS_CAIRO := \
  -Dcairo:xlib=disabled \
  -Dcairo:xcb=disabled \
  -Dcairo:tests=disabled \

MESON_FLAGS_PIXMAN := \
  -Dpixman:tests=disabled \

MESON_FLAGS_LIBEPOXY := \
  -Dlibepoxy:x11=false \

MESON_FLAGS_GRAPHENE := \
  -Dgraphene:c_std=gnu99 \
  -Dgraphene:introspection=disabled \
  -Dgraphene:tests=false \
  -Dgraphene:installed_tests=false \

MESON_FLAGS_PANGO := \
  -Dpango:libthai=disabled \

MESON_FLAGS_ATK := \
  -Datk:introspection=disabled \

MESON_FLAGS_HARFBUZZ := \
  -Dharfbuzz:tests=disabled \

MESON_FLAGS := \
  --buildtype=$(MESON_BUILD_TYPE) \
  -Dprefix=$(INSTALL_ROOT_WITH_PREFIX) \
  $(MESON_FLAGS_GLIB) $(MESON_FLAGS_GDK_PIXBUF) \
  $(MESON_FLAGS_CAIRO) $(MESON_FLAGS_PIXMAN) \
  $(MESON_FLAGS_LIBEPOXY) $(MESON_FLAGS_GRAPHENE) \
  $(MESON_FLAGS_PANGO) $(MESON_FLAGS_ATK) \
  $(MESON_FLAGS_HARFBUZZ) $(MESON_FLAGS_GTK4)

# Use submoduled Meson
MESON := $(QNX_PROJECT_ROOT)/../meson/meson.py
# Use system ninja
NINJA := ninja

NINJA_ARGS := -j $(firstword $(JLEVEL) 1)

# Prebuilt files
define prebuilt-targets
  $(subst $(PROJECT_ROOT)/prebuilt/$(1),$(INSTALL_ROOT_WITH_PREFIX),$(shell find $(PROJECT_ROOT)/prebuilt/$(1)/ -type f))
endef
define prebuilt-target-to-source
  $(subst $(INSTALL_ROOT_WITH_PREFIX),$(PROJECT_ROOT)/prebuilt/$(1),$(2))
endef

PREBUILT_TARGETS := $(call prebuilt-targets,common)
PREBUILT_ARCH_TARGETS := $(call prebuilt-targets,$(CPUVARDIR))

qnx_cross.cfg: $(PROJECT_ROOT)/qnx_cross.cfg.in
	cp $(PROJECT_ROOT)/qnx_cross.cfg.in $@
	sed -i "s|PKG_CONFIG|$(PROJECT_ROOT)/pkg-config-wrapper.sh|" $@
	sed -i "s|QNX_HOST|$(QNX_HOST)|" $@
	sed -i "s|TARGET_ARCH|$(CPU)|" $@
	sed -i "s|CPUDIR|$(CPUVARDIR)|" $@
	sed -i "s|QNX_TARGET_BIN_DIR|$(QNX_TARGET)/$(CPUVARDIR)|" $@
	# PREPEND_C_CXXFLAGS need to be converted to Meson list format
	sed -i "s|PREPEND_C_CXXFLAGS|$(foreach flag,$(PREPEND_C_CXXFLAGS),'$(flag)',)|" $@

# Meson setup configures the ninja build file.
# Reconfiguration is required if any of the prebuilt toolchain files change.
# Thus the requisite includes all prebuilt files, and meson is invoked with --reconfigure.
build/build.ninja: qnx_cross.cfg $(PREBUILT_TARGETS) $(PREBUILT_ARCH_TARGETS)
	mkdir -p build && cd build && \
		$(MESON) setup --reconfigure --cross-file=../qnx_cross.cfg $(MESON_FLAGS) . $(QNX_PROJECT_ROOT)

gtk4_all: build/build.ninja
	cd build && $(NINJA) $(NINJA_ARGS)

install check: gtk4_all
	cd build && $(NINJA) install
	glib-compile-schemas $(INSTALL_ROOT_WITH_PREFIX)/share/glib-2.0/schemas

clean:
	rm -rf qnx_cross.cfg
	rm -rf build

# Rules to install prebuilt files under the prebuilt/ directory
# These come last because they need secondary expansion as a result
# of the need to use prebuilt-target-to-source in requisites.
# These prebuilt files need to be installed first under INSTALL_ROOT.
.SECONDEXPANSION:
$(PREBUILT_TARGETS): %: $$(call prebuilt-target-to-source,common,$$@)
$(PREBUILT_ARCH_TARGETS): %: $$(call prebuilt-target-to-source,$(CPUVARDIR),$$@)

$(PREBUILT_TARGETS) $(PREBUILT_ARCH_TARGETS):
	mkdir -p $(@D)
	cp $< $@
