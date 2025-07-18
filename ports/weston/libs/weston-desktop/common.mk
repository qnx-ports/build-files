ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/libweston/desktop
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
include ../../../../../extra_incvpath.mk

EXTRA_SRCVPATH += $(DIST_ROOT)/libweston/desktop
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^so\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston/$(OS)/$(CPU)/$(VARIANT1)

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	client.c \
	libweston-desktop.c \
	seat.c \
	surface.c \
	xdg-shell-v6.c \
	xdg-shell.c \
	xwayland.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	xdg-shell-unstable-v6-protocol.c \
	xdg-shell-protocol.c

LIBS += weston sharedS wayland-server pixman-1 m

define PINFO
PINFO DESCRIPTION = Weston Desktop Library
endef

include $(MKFILES_ROOT)/qtargets.mk
