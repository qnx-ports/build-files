ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/libweston
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/compositor
EXTRA_SRCVPATH += $(DIST_ROOT)/shell-utils
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_SRCVPATH += $(DIST_ROOT)/shared
# Stops build system from setting INCVPATH=$(EXTRA_SRCVPATH)
# Will still append EXTRA_INCVPATH as expected.
INCVPATH = $(empty)

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston-desktop/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^so\(.*\)$$/a.shared\1/')

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	main.c \
	weston-screenshooter.c \
	text-backend.c \
	shell-utils.c \
	weston-screenshooter-protocol.c \
	text-input-unstable-v1-protocol.c \
	input-method-unstable-v1-protocol.c

LIBS += weston weston-desktop sharedS wayland-server pixman-1 memstream epoll socket

define PINFO
PINFO DESCRIPTION = Weston Exec Library
endef

include $(MKFILES_ROOT)/qtargets.mk
