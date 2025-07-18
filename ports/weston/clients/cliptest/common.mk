ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-cliptest

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/bin

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))
include ../../../../../extra_incvpath.mk

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(DIST_ROOT)/libweston
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared-cairo/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/toytoolkit/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')

SRCS += \
	cliptest.c \
	vertex-clipping.c

LIBS += \
	toytoolkitS \
	shared-cairoS \
	cairo \
	pixman-1 \
	xkbcommon \
	wayland-egl \
	wayland-cursor \
	wayland-client \
	EGL \
	epoll \
	timerfd \
	socket \
	jpeg \
	png \
	m

define PINFO
PINFO DESCRIPTION = Weston Clip Test Client
endef

include $(MKFILES_ROOT)/qtargets.mk
