ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk

NAME=mame

## Set up user-overridden variables
QNX_PROJECT_ROOT    ?= $(PRODUCT_ROOT)/../../$(NAME)
PREFIX              ?= usr/local

PKG_CONFIG_PATH = $(QNX_TARGET)/$(CPUVARDIR)/usr/lib/pkgconfig:$(INSTALL_ROOT)/$(CPUVARDIR)/usr/lib/pkgconfig


## Set up QNX recursive makefile specifics.
.PHONY: $(NAME)_all install clean
ALL_DEPENDENCIES = $(NAME)_all
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

##########Pre-Target Def############
include $(MKFILES_ROOT)/qtargets.mk
##########Post-Target Def###########

TARGETOS=qnx

$(NAME)_all:
	@echo ===============
	@echo Building $(NAME)...
	@echo ===============
	@mkdir -p build
	@cd build && PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) TARGETOS=$(TARGETOS) make -C $(QNX_PROJECT_ROOT) qnx_$(CPU)


install: $(NAME)_all
	@echo Install not yet supported.

clean:
	@rm -rf build
