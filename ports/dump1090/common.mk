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
CFLAGS += -D_QNX_SOURCE -g -O0
LDFLAGS += -lrtlsdr -lm  -lsocket
CFLAGS += -DQNX=1


include $(MKFILES_ROOT)/qtargets.mk

QNX_VARIANT = -Vgcc_nto$(CPUVARDIR)

$(NAME)_all:
	@mkdir -p build
	@cd build && $(MAKE) -C $(QNX_PROJECT_ROOT) \
		CC="qcc $(QNX_VARIANT)" \
		OBJDIR=$(CURDIR)/build \
		CFLAGS="$(CFLAGS)" \
		LDLIBS="$(LDFLAGS)"

install:
	install build/$(NAME) \
	        $(INSTALL_ROOT)/$(CPUVARDIR)/usr/bin/
check:
	@echo "No tests for dump1090"

clean iclean spotless:
	$(MAKE) -C $(QNX_PROJECT_ROOT) OBJDIR=$(CURDIR)/build clean
