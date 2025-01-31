ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

# undefine NDEBUG
NDEBUG=

DIST_ROOT ?= $(PROJECT_ROOT)/../../../Wayland

EXTRA_INCVPATH += $(DIST_ROOT)/src
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../wayland-server/$(OS)/protocol
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../wayland-client/$(OS)/protocol
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../tests/$(OS)/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/tests
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../tests/$(OS)/protocol

LIBS += test-runner wayland-server wayland-client socket

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../test-runner/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../wayland-server/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a\1/')

SRCS = $(PROJECT).c tests-protocol.c
NAME=test-wayland-$(PROJECT)
USEFILE=
INSTALLDIR=usr/bin

define PINFO
endef

include $(MKFILES_ROOT)/qtargets.mk
