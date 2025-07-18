ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/sbin

EXTRA_INCVPATH += $(DIST_ROOT)/compositor
EXTRA_INCVPATH += $(DIST_ROOT)/libweston
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../backends/qnx-screen
EXTRA_INCVPATH += $(PROJECT_ROOT)/../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../$(OS)/libweston
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
include ../../../../extra_incvpath.mk

EXTRA_SRCVPATH += $(DIST_ROOT)/compositor
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../$(OS)

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../libs/weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../libs/weston-exec/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/so\1/')

LDFLAGS += -Wl,--export-dynamic
# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL

SRCS += \
	executable.c

LIBS += weston-exec sharedS wayland-server socket memstream

define PINFO
PINFO DESCRIPTION = Weston Compositor
endef

include $(MKFILES_ROOT)/qtargets.mk
