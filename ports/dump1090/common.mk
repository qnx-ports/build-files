ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME = dump1090

# Where dump1090 source lives
QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# Override default QNX build
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install clean check

# QNX flags
CFLAGS += -D_QNX_SOURCE
LDFLAGS += -lrtlsdr -lm -lpthread

include $(MKFILES_ROOT)/qtargets.mk


$(NAME)_all:
	$(MAKE) -C $(QNX_PROJECT_ROOT) \
		CC=$(CC) \
		CFLAGS="$(CFLAGS)" \
		LDLIBS="$(LDFLAGS)"

install:
	install -d $(INSTALL_ROOT)/$(CPUVARDIR)/usr/bin
	install $(QNX_PROJECT_ROOT)/dump1090 \
	        $(INSTALL_ROOT)/$(CPUVARDIR)/usr/bin/

check:
	@echo "No tests for dump1090"

clean iclean spotless:
	$(MAKE) -C $(QNX_PROJECT_ROOT) clean
