# SPDX-License-Identifier: MIT
.PHONY: all install hinstall clean iclean verify uninstall
all install hinstall:
	python3 "$(QNX_PROJECT_ROOT)/scripts/fetch-upstream.py"
	python3 "$(QNX_PROJECT_ROOT)/scripts/prepare-upstream.py" "$(QFUSE_PORT_DIR)/build/generated"
clean iclean verify uninstall:
	@:
