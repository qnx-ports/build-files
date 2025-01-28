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

# The host scanner must be built during an hinstall because it's used to generate
# headers that are hinstalled.  engserv builds set HINSTALL_HOST_TOOLS to indicate
# that all host tools should be built during the hinstall.
hinstall: $(if $(or $(HINSTALL_HOST_TOOLS),$(filter $(OS),$(HOST_OS))),install,)
