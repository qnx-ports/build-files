ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)/../../Wayland
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/egl
EXTRA_INCVPATH += $(DIST_ROOT)/src
EXTRA_INCVPATH += $(PROJECT_ROOT)/../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../wayland-client/$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/egl

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS = wayland-egl.c

PUBLIC_HEADERS = \
	$(DIST_ROOT)/egl/wayland-egl.h \
	$(DIST_ROOT)/egl/wayland-egl-backend.h \
	$(DIST_ROOT)/egl/wayland-egl-core.h

# Trigger the TARGET_HINSTALL/HUNINSTALL overrides
PUBLIC_INCVPATH = $(space)

define PINFO
PINFO DESCRIPTION = Wayland EGL API
endef

include $(MKFILES_ROOT)/qtargets.mk

define TARGET_HINSTALL
	$(CP_HOST) $(PUBLIC_HEADERS) $(INSTALL_ROOT_HDR)
endef

define TARGET_HUNINSTALL
	$(RM_HOST) $(foreach header,$(PUBLIC_HEADERS),$(INSTALL_ROOT_HDR)/$(notdir $(header)))
endef
