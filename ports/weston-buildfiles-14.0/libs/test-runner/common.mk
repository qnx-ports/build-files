ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))


EXTRA_SRCVPATH += $(DIST_ROOT)/tests

SRCS +=	weston-test-runner.c

LIBS += wayland-client wayland-server pixman-1 xkbcommon
NDEBUG =
include $(MKFILES_ROOT)/qtargets.mk
