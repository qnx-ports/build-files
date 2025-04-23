ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)/../../Wayland
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/cursor
EXTRA_INCVPATH += $(DIST_ROOT)/src
EXTRA_INCVPATH += $(PROJECT_ROOT)/../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../wayland-client/$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/cursor
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../wayland-client/$(OS)/$(CPU)/$(VARIANT1)

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS = wayland-cursor.c os-compatibility.c xcursor.c
LIBS += wayland-client

# Trigger the TARGET_HINSTALL/HUNINSTALL overrides
PUBLIC_INCVPATH = $(space)

define PINFO
PINFO DESCRIPTION = Wayland Cursor API
endef

include $(MKFILES_ROOT)/qtargets.mk

define TARGET_HINSTALL
	$(CP_HOST) $(DIST_ROOT)/cursor/wayland-cursor.h $(INSTALL_ROOT_HDR)
endef

define TARGET_HUNINSTALL
	$(RM_HOST) $(INSTALL_ROOT_HDR)/wayland-cursor.h
endef
