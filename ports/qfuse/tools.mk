# SPDX-License-Identifier: MIT
# Optional owner-local SDK emulator supervision; ordinary Linux builds omit it.
ifneq ($(strip $(QFUSE_TOOL_WRAPPER)),)
CCWRAP := $(QFUSE_TOOL_WRAPPER) $(CCWRAP)
LDPREF := $(QFUSE_TOOL_WRAPPER) $(LDPREF)
ARPREF := $(QFUSE_TOOL_WRAPPER) $(ARPREF)
endif
.PHONY: verify
verify:
	@:
