ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

BUILD_TESTS ?= "true"

DIST_BASE="../../../../libxml2"
ifdef QNX_PROJECT_ROOT
DIST_BASE=$(QNX_PROJECT_ROOT)
endif

ifndef NO_TARGET_OVERRIDE
clean iclean spotless:
	rm -fr build
	cd nto-aarch64-le && find . ! -name '*.' -type d -exec rm -rf {} +
	cd nto-aarch64-le && find . ! -name 'GNUmakefile' -type f -exec rm -f {} +
	cd nto-x86_64-o && find . ! -name '*.' -type d -exec rm -rf {} +
	cd nto-x86_64-o && find . ! -name 'GNUmakefile' -type f -exec rm -f {} +
	
uninstall:
endif