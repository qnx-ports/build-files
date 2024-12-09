ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

BUILD_TESTS ?= "true"

DIST_BASE="../../../../libxml2"
ifdef QNX_PROJECT_ROOT
DIST_BASE=$QNX_PROJECT_ROOT
endif

ifndef NO_TARGET_OVERRIDE
clean iclean spotless:
	rm -fr build

uninstall:
endif