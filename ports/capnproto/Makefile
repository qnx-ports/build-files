HOST_TARGET := linux-x86_64-o
TARGETS := $(HOST_TARGET) nto-aarch64-le nto-x86_64-o
INSTALL_TARGETS := $(foreach target, $(TARGETS), install-$(target))
CLEAN_TARGETS := $(foreach target, $(TARGETS), clean-$(target))

.PHONY: all install clean $(INSTALL_TARGETS) $(CLEAN_TARGETS)
all: install

install: $(INSTALL_TARGETS)

clean: $(CLEAN_TARGETS)

$(CLEAN_TARGETS):
	$(MAKE) -C $(subst clean-,,$@) clean

$(INSTALL_TARGETS):
	$(MAKE) -C $(subst install-,,$@) install

$(filter-out $(HOST_TARGET), $(INSTALL_TARGETS)): install-$(HOST_TARGET)
