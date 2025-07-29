ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif

EARLY_DIRS = \
	shared \
	shared-cairo \
	weston \
	weston-desktop \
	weston-exec \
	desktop-shell \
	hmi-controller \
	ivi-shell \
	fullscreen-shell \
	screen-share \
	toytoolkit

include $(QRDIR)$(QRECURSE)
