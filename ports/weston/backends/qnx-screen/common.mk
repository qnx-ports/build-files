ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = qnx-screen-backend

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib/libweston

EXTRA_INCVPATH += $(DIST_ROOT)/libweston
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	qnx-screen.c \
	qnx-screen-event-monitor.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	presentation-time-protocol.c
LIBS += weston sharedS wayland-server xkbcommon pixman-1 screen

define PINFO
PINFO DESCRIPTION = Weston QNX Screen Backend Library
endef

include $(MKFILES_ROOT)/qtargets.mk
