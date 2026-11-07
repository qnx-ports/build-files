# SPDX-License-Identifier: MIT
# Native QNX recursive build; source remains in a separate checkout.
.NOTPARALLEL:
QFUSE_PORT_DIR := $(CURDIR)
export QFUSE_PORT_DIR
QNX_PROJECT_ROOT ?= $(abspath $(CURDIR)/../../../qfuse)
override QNX_PROJECT_ROOT := $(abspath $(QNX_PROJECT_ROOT))
export QNX_PROJECT_ROOT
INSTALL_ROOT_nto ?= $(QFUSE_PORT_DIR)/stage
override INSTALL_ROOT_nto := $(abspath $(INSTALL_ROOT_nto))
export INSTALL_ROOT_nto
PREFIX ?= /usr/local
export PREFIX
QNX_NO_IGNORE := 1
export QNX_NO_IGNORE
ifneq ($(origin CPU),undefined)
$(error Select CPULIST=aarch64 or CPULIST=x86_64; CPU is inferred by QNX)
endif
ifeq ($(INSTALL_ROOT_nto),/)
$(error INSTALL_ROOT_nto must be a private staging directory)
endif
ifneq ($(strip $(QNX_TARGET)),)
ifneq ($(filter $(abspath $(QNX_TARGET))%,$(INSTALL_ROOT_nto)),)
$(error INSTALL_ROOT_nto must stay outside the licensed SDP)
endif
endif
EARLY_DIRS := prepare library
LATE_DIRS := package
ifneq ($(filter uninstall,$(MAKECMDGOALS)),)
ifneq ($(strip $(filter-out uninstall,$(MAKECMDGOALS))),)
$(error Run uninstall separately from build/install goals)
endif
.PHONY: uninstall
uninstall:
	$(MAKE) -C package uninstall
else
LIST := PROJECT
include recurse.mk
endif
