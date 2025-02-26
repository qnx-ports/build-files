ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif

EARLY_DIRS = \
	libs \
	renderers \
	backends \
	weston \
	clients \
	tests

include $(QRDIR)$(QRECURSE)
