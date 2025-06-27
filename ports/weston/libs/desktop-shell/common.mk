ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib/weston

EXTRA_INCVPATH += $(DIST_ROOT)/desktop-shell
EXTRA_INCVPATH += $(DIST_ROOT)/shell-utils
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/desktop-shell
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston-desktop/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../weston-exec/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
# Can't.  It's linked to symbols in the weston executable.
# LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	shell.c \
	input-panel.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	input-method-unstable-v1-protocol.c \
	weston-desktop-shell-protocol.c

LIBS += weston weston-exec sharedS wayland-server pixman-1 m

define PINFO
PINFO DESCRIPTION = Weston Desktop Shell Library
endef

include $(MKFILES_ROOT)/qtargets.mk
