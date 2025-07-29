ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib/weston

EXTRA_INCVPATH += $(DIST_ROOT)/ivi-shell
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
include ../../../../../extra_incvpath.mk

EXTRA_SRCVPATH += $(DIST_ROOT)/ivi-shell
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
CCFLAGS += -Wno-unused-but-set-variable
# Report unresolved symbols at build time
# Can't.  It's linked to symbols in the weston executable.
# LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	hmi-controller.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	ivi-hmi-controller-protocol.c
LIBS += weston sharedS wayland-server

define PINFO
PINFO DESCRIPTION = Weston HMI Controller Library
endef

include $(MKFILES_ROOT)/qtargets.mk
