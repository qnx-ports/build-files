ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmake-cfg.mk

ifndef NO_TARGET_OVERRIDE
clean:
	@ls -A | grep -v "GNUmakefile" | xargs -n 1 rm -rf
endif
