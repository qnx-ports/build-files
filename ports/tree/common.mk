ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk
NAME = tree

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../$(NAME)

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# QNX flags
CFLAGS += -D_QNX_SOURCE

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install clean check iclean spotless

BUILD_DIR := $(CURDIR)/build

$(NAME)_all:
	@echo "Building $(NAME) for $(CPUVARDIR)"

	@rm -rf $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)

	@rsync -a \
		--exclude=.git \
		$(QNX_PROJECT_ROOT)/ \
		$(BUILD_DIR)/

	@$(MAKE) -C $(BUILD_DIR) \
		CC="qcc -Vgcc_nto$(CPUVARDIR)" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)"

install: $(NAME)_all
	mkdir -p $(INSTALL_ROOT)/$(CPUVARDIR)/usr/local/bin
	install -m 755 \
		$(BUILD_DIR)/tree \
		$(INSTALL_ROOT)/$(CPUVARDIR)/usr/local/bin/tree

check:
	@echo "No tests for tree"

clean iclean spotless:
	rm -rf build
	$(MAKE) -C $(QNX_PROJECT_ROOT) clean