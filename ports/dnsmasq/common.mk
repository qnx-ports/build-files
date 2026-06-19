ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
include $(MKFILES_ROOT)/qmacros.mk
NAME = dnsmasq

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# QNX flags
CFLAGS += -D_QNX_SOURCE
LDFLAGS += -lm -lc

# Handle io-sock for QNX SDP 7.1 (not needed for 8.0+)
ifeq ($(USE_IOSOCK),true)
ifeq ($(wildcard $(QNX_TARGET)/$(CPUVARDIR)/io-sock),)
$(error USE_IOSOCK is defined but io-sock is not found inside SDP. Note that io-sock is already the default network stack since QNX SDP 8.0.0. For SDP 7.1.0 and earlier, please ensure io-sock is downloaded via QSC first.)
endif
$(info Linking to io-sock libsocket...)
CFLAGS += -I$(QNX_TARGET)/usr/include/io-sock
LDFLAGS += -L$(QNX_TARGET)/$(CPUVARDIR)/io-sock/lib -lsocket
else
LDFLAGS += -lsocket
endif

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install clean check iclean spotless

$(NAME)_all:
	@echo "Building dnsmasq with LDFLAGS: $(LDFLAGS)"
	@mkdir -p build
	@cd build && $(MAKE) -C $(QNX_PROJECT_ROOT) \
		CC="qcc -Vgcc_nto$(CPUVARDIR)" \
		BUILDDIR=$(CURDIR)/build \
		LDFLAGS="$(LDFLAGS)" \
		CFLAGS="$(CFLAGS)"

install: $(NAME)_all
	mkdir -p $(INSTALL_ROOT)/$(CPUVARDIR)/usr/bin
	install -m 755 build/dnsmasq $(INSTALL_ROOT)/$(CPUVARDIR)/usr/bin/

check:
	@echo "No tests for dnsmasq"

clean iclean spotless:
	rm -rf build
	$(MAKE) -C $(QNX_PROJECT_ROOT) clean