ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-simple-egl

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/bin

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/shared

# Stops build system from setting INCVPATH=$(EXTRA_SRCVPATH)
# Will still append EXTRA_INCVPATH as expected. There is a
# signal.h file in weston source conflicting with OS signal.h
INCVPATH = $(empty)

SRCS += \
	matrix.c \
	simple-egl.c \
	xdg-shell-protocol.c \
	xdg-shell-unstable-v6-protocol.c \
	ivi-application-protocol.c

LIBS += wayland-cursor wayland-egl wayland-client EGL GLESv2 m

define PINFO
PINFO DESCRIPTION = Weston Simple EGL Client
endef

include $(MKFILES_ROOT)/qtargets.mk
