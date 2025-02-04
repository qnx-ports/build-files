ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

# undefine NDEBUG
NDEBUG=

DIST_ROOT ?= $(PROJECT_ROOT)/../../../Wayland
INSTALLDIR=/dev/null

EXTRA_INCVPATH += $(DIST_ROOT)/src
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../wayland-server/nto/protocol
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../wayland-client/nto/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/tests

SRCS = \
	test-runner.c \
	test-helpers.c \
	test-compositor.c \

include $(MKFILES_ROOT)/qtargets.mk
