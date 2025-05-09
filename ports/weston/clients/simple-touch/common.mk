ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-simple-touch

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/bin

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/shared

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')

# Stops build system from setting INCVPATH=$(EXTRA_SRCVPATH)
# Will still append EXTRA_INCVPATH as expected. There is a
# signal.h file in weston source conflicting with OS signal.h
INCVPATH = $(empty)

SRCS += \
	simple-touch.c \
	epoll-create-stub.c \
	socketpair-stub.c \
	xdg-shell-protocol.c

LIBS += sharedS wayland-client

define PINFO
PINFO DESCRIPTION = Weston Simple Touch Client
endef

include $(MKFILES_ROOT)/qtargets.mk
