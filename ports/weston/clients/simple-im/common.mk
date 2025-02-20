ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = weston-simple-im

INSTALLDIR = usr/libexec

DIST_ROOT ?= $(PROJECT_ROOT)

EXTRA_INCVPATH += $(DIST_ROOT)/clients
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/clients
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')

SRCS += \
	simple-im.c \
	epoll-create-stub.c \
	socketpair-stub.c \
	fullscreen-shell-unstable-v1-protocol.c \
	ivi-application-protocol.c \
	xdg-shell-protocol.c \
	input-method-unstable-v1-protocol.c

LIBS += sharedS wayland-client xkbcommon

define PINFO
PINFO DESCRIPTION = Weston Simple Input Method Client
endef

include $(MKFILES_ROOT)/qtargets.mk
