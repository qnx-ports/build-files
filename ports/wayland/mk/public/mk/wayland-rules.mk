include $(WAYLAND_MKFILES_ROOT)wayland-macros.mk

# <basename>-vN --> <basename>
protocol_name_staging = $(shell echo $(1) | sed 's/\([a-z\-]\{1,\}\)-v[0-9]\{1,\}/\1/')
# <basename>-<something>-vN --> <basename>
protocol_name_unstable = $(shell echo $(1) | sed 's/\([a-z\-]\{1,\}\)-unstable-v[0-9]\{1,\}/\1/')
protocol_code_type = $(if $($(1)_CODE_TYPE), $($(1)_CODE_TYPE), $(PROTOCOL_CODE_TYPE))

vpath %.xml $(call _vpath_normalize,$(PROTOCOLVPATH))

.SECONDEXPANSION:

# stable
$(PROTOCOL_ROOT)/%-protocol.c : stable/$$*/$$*.xml
	$(WAYLAND_SCANNER_HOST) $(call protocol_code_type,$*) < $< > $@
$(PROTOCOL_ROOT)/%-server-protocol.h : stable/$$*/$$*.xml
	$(WAYLAND_SCANNER_HOST) server-header < $< > $@
$(PROTOCOL_ROOT)/%-client-protocol.h : stable/$$*/$$*.xml
	$(WAYLAND_SCANNER_HOST) client-header < $< > $@

# staging
$(PROTOCOL_ROOT)/%-protocol.c : staging/$$(call protocol_name_staging,$$*)/$$*.xml
	$(WAYLAND_SCANNER_HOST) $(call protocol_code_type,$*) < $< > $@
$(PROTOCOL_ROOT)/%-server-protocol.h : staging/$$(call protocol_name_staging,$$*)/$$*.xml
	$(WAYLAND_SCANNER_HOST) server-header < $< > $@
$(PROTOCOL_ROOT)/%-client-protocol.h : staging/$$(call protocol_name_staging,$$*)/$$*.xml
	$(WAYLAND_SCANNER_HOST) client-header < $< > $@

# unstable
$(PROTOCOL_ROOT)/%-protocol.c : unstable/$$(call protocol_name_unstable,$$*)/$$*.xml
	$(WAYLAND_SCANNER_HOST) $(call protocol_code_type,$*) < $< > $@
$(PROTOCOL_ROOT)/%-server-protocol.h : unstable/$$(call protocol_name_unstable,$$*)/$$*.xml
	$(WAYLAND_SCANNER_HOST) server-header < $< > $@
$(PROTOCOL_ROOT)/%-client-protocol.h : unstable/$$(call protocol_name_unstable,$$*)/$$*.xml
	$(WAYLAND_SCANNER_HOST) client-header < $< > $@

# internal (custom)
$(PROTOCOL_ROOT)/%-protocol.c : %.xml
	$(WAYLAND_SCANNER_HOST) $(call protocol_code_type,$*) < $< > $@

$(PROTOCOL_ROOT)/%-server-protocol.h : %.xml
	$(WAYLAND_SCANNER_HOST) server-header < $< > $@

$(PROTOCOL_ROOT)/%-client-protocol.h : %.xml
	$(WAYLAND_SCANNER_HOST) client-header < $< > $@
