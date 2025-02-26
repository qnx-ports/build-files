ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)/../../Wayland
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/src
EXTRA_INCVPATH += $(PROJECT_ROOT)/../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/$(OS)/protocol
EXTRA_SRCVPATH += $(DIST_ROOT)/src
EXTRA_SRCVPATH += $(PROJECT_ROOT)/$(OS)/protocol

EXTRA_INCVPATH += $(addsuffix /libffi-3.2.1/include,$(filter %/usr/lib,$(USE_ROOT_LIB)))

EXTRA_LIBVPATH += $(addsuffix /libffi-3.2.1,$(filter %/usr/lib,$(USE_ROOT_LIB)))

CCFLAGS += -Wno-unused-but-set-variable -Wno-unused-variable

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

PROTOCOLS += wayland
SRCS += wayland-protocol.c wayland-server.c wayland-shm.c wayland-os.c wayland-util.c connection.c event-loop.c
LIBS += ffi socket epoll timerfd signalfd memstream eventfd

PUBLIC_HEADERS = \
	$(DIST_ROOT)/src/wayland-server.h \
	$(DIST_ROOT)/src/wayland-server-core.h \
	$(PROJECT_ROOT)/$(OS)/protocol/wayland-server-protocol.h \
	$(DIST_ROOT)/src/wayland-util.h \
	$(DIST_ROOT)/src/wayland-version.h \
	$(QNX_TARGET)/usr/include/sys/memstream.h

# Trigger the TARGET_HINSTALL/HUNINSTALL overrides
PUBLIC_INCVPATH = $(space)

define PINFO
PINFO DESCRIPTION = Wayland Server API
endef

include $(MKFILES_ROOT)/qtargets.mk

define TARGET_HINSTALL
	$(CP_HOST) $(PUBLIC_HEADERS) $(INSTALL_ROOT_HDR)
endef

define TARGET_HUNINSTALL
	$(RM_HOST) $(foreach header,$(PUBLIC_HEADERS),$(INSTALL_ROOT_HDR)/$(notdir $(header)))
endef
