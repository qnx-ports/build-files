ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)/libweston
EXTRA_INCVPATH += $(DIST_ROOT)/compositor
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/tests
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

SRCS +=	\
	weston-test.c \
	weston-test-protocol.c

include $(MKFILES_ROOT)/qtargets.mk
