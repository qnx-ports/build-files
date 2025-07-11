ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif

EARLY_DIRS = \
	headers \
	libs \
	renderers \
	backends \
	weston \
	clients \
	tests

include $(QRDIR)$(QRECURSE)
