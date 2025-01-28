ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif

EARLY_DIRS = wayland-scanner mk wayland-client wayland-server wayland-egl wayland-cursor

include $(QRDIR)$(QRECURSE)
