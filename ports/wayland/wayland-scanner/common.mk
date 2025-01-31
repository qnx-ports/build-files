ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

INSTALLDIR=$(firstword $(INSTALLDIR_$(OS)) usr/bin)

EXTRA_INCVPATH=$(DIST_ROOT)/src
EXTRA_INCVPATH=$(PROJECT_ROOT)/../$(OS)
EXTRA_SRCVPATH=$(DIST_ROOT)/src

CPPFLAGS += -include config.h
SRCS = scanner.c wayland-util.c
LIBS+= expat

define PINFO
PINFO DESCRIPTION = Generate code/headers from Wayland protocol definitions
endef

include $(MKFILES_ROOT)/qtargets.mk

hinstall: $(if $(or $(HINSTALL_HOST_TOOLS),$(filter $(OS),$(HOST_OS))),install,)
