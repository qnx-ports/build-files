ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/tools/zunitc/inc
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)

EXTRA_SRCVPATH += $(DIST_ROOT)/tools/zunitc/src/

SRCS +=	main.c

LIBS += zunitcS sharedS

include $(MKFILES_ROOT)/qtargets.mk
