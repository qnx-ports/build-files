LIST=OS CPU
ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif
include $(QRDIR)$(QRECURSE)

JLEVEL ?= $(subst -j,,$(filter -j%,$(MAKEFLAGS)))
