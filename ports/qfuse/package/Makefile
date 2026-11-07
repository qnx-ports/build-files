# SPDX-License-Identifier: MIT
QFUSE_ARCHS := $(if $(strip $(CPULIST)),$(subst aarch64,aarch64le,$(CPULIST)),aarch64le x86_64)
.PHONY: all install hinstall verify uninstall clean iclean
all clean iclean:
	@:
install:
	python3 "$(QNX_PROJECT_ROOT)/scripts/native-port.py" install --stage "$(INSTALL_ROOT_nto)" --prefix "$(PREFIX)" --generated "$(QFUSE_PORT_DIR)/build/generated" --architectures $(QFUSE_ARCHS)
hinstall:
	python3 "$(QNX_PROJECT_ROOT)/scripts/native-port.py" headers --stage "$(INSTALL_ROOT_nto)" --prefix "$(PREFIX)" --generated "$(QFUSE_PORT_DIR)/build/generated" --architectures $(QFUSE_ARCHS)
verify uninstall:
	python3 "$(QNX_PROJECT_ROOT)/scripts/native-port.py" $@ --stage "$(INSTALL_ROOT_nto)" --prefix "$(PREFIX)" --architectures $(QFUSE_ARCHS)
