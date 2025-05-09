ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-editor

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/bin

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)/shared
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /pango-1.0,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /glib-2.0,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /glib-2.0/include,$(filter %/usr/lib,$(USE_ROOT_LIB)))

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/shared

SRCS += \
	editor.c \
	text-input-unstable-v1-protocol.c

LIBS += \
	toytoolkitS \
	shared-cairoS \
	pangocairo-1.0 \
	pango-1.0 \
	cairo \
	pixman-1 \
	glib-2.0 \
	gobject-2.0 \
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
PINFO DESCRIPTION = Weston Editor Client
endef

include $(MKFILES_ROOT)/qtargets.mk
