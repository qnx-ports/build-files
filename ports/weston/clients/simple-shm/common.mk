ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-simple-shm

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/bin

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')

SRCS += \
	simple-shm.c \
	epoll-create-stub.c \
	socketpair-stub.c \
	fullscreen-shell-unstable-v1-protocol.c \
	xdg-shell-protocol.c

LIBS += sharedS wayland-client

define PINFO
PINFO DESCRIPTION = Weston Simple Shared Memory Client
endef

include $(MKFILES_ROOT)/qtargets.mk
