ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

BUILD_TESTS ?= "true"
INSTALL_ROOT ?= ${INSTALL_ROOT_${OS}}

ifndef NO_TARGET_OVERRIDE
clean iclean spotless:
	rm -fr build
endif