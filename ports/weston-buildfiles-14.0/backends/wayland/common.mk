ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = wayland-backend

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib/libweston

EXTRA_INCVPATH += $(DIST_ROOT)/libweston
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../libs/weston/$(OS)/protocol
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /libdrm,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/libweston/backend-wayland
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared-cairo/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')

LIBS += weston wayland-server pixman-1

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	wayland.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	xdg-shell-protocol.c \
	fullscreen-shell-unstable-v1-protocol.c \
	xdg-shell-unstable-v6-protocol.c
LIBS += shared-cairoS wayland-egl wayland-cursor wayland-client xkbcommon cairo jpeg png m

define PINFO
PINFO DESCRIPTION = Weston Wayland Backend Library
endef

include $(MKFILES_ROOT)/qtargets.mk
