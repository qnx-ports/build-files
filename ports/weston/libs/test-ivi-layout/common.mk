ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/tests

SRCS += ivi-layout-test-plugin.c weston-test-protocol.c

LIBS += weston-exec weston wayland-server pixman-1 xkbcommon

include $(MKFILES_ROOT)/qtargets.mk
