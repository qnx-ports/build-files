# SPDX-License-Identifier: MIT
# QNX SDP 8.0 build recipe; keep the source checkout separate from build-files.
SHELL := /bin/bash
.DEFAULT_GOAL := all
CPU ?= x86_64
QNX_PROJECT_ROOT ?= $(abspath $(CURDIR)/../../../qfuse)
QFUSE_SOURCE_DIR ?= $(QNX_PROJECT_ROOT)
export QFUSE_ARCH := $(CPU)
QFUSE_BUILD_PARENT ?= $(CURDIR)/build/$(CPU)
QNX_SDP_ROOT ?= $(abspath $(QNX_HOST)/../../..)
PREFIX ?= /usr/local
INSTALL_ROOT_nto ?= $(CURDIR)/stage/$(CPU)
QFUSE_PORT_PREFIX := $(abspath $(INSTALL_ROOT_nto))$(PREFIX)
QFUSE_ARTIFACT_ROOT := $(abspath $(QFUSE_BUILD_PARENT))/latest/build/qnx

.PHONY: all install check-source verify uninstall
check-source:
	@test -f "$(QFUSE_SOURCE_DIR)/scripts/build-linux.sh" || { echo 'Set QFUSE_SOURCE_DIR to the QFuse source checkout' >&2; exit 2; }
	@test -f "$(QNX_SDP_ROOT)/qnxsdp-env.sh" || { echo 'Source your licensed SDP or set QNX_SDP_ROOT' >&2; exit 2; }
	@test "$(CPU)" = 'x86_64' -o "$(CPU)" = 'aarch64le' || { echo 'Select CPU=x86_64 or CPU=aarch64le' >&2; exit 2; }
	@test "$(PREFIX)" != '/' && [[ "$(PREFIX)" == /* ]] || { echo 'PREFIX must be an absolute non-root path' >&2; exit 2; }
all: check-source
	cd "$(QFUSE_SOURCE_DIR)" && python3 scripts/fetch-upstream.py
	cd "$(QFUSE_SOURCE_DIR)" && QNX_SDP_ROOT="$(QNX_SDP_ROOT)" QFUSE_BUILD_PARENT="$(abspath $(QFUSE_BUILD_PARENT))" bash scripts/build-linux.sh --mount
install: all
	cd "$(QFUSE_SOURCE_DIR)" && QNX_SDP_ROOT="$(QNX_SDP_ROOT)" QFUSE_ARTIFACT_ROOT="$(QFUSE_ARTIFACT_ROOT)" QFUSE_INSTALL_PREFIX="$(QFUSE_PORT_PREFIX)" bash scripts/package-qnx.sh
verify: check-source
	cd "$(QFUSE_SOURCE_DIR)" && source "$(QNX_SDP_ROOT)/qnxsdp-env.sh" >/dev/null && project_root="$(QFUSE_SOURCE_DIR)" && source scripts/qnx-compiler-env.sh && QFUSE_ARTIFACT_ROOT="$(QFUSE_ARTIFACT_ROOT)" QFUSE_INSTALL_PREFIX="$(QFUSE_PORT_PREFIX)" python3 scripts/verify-package.py
uninstall: check-source
	python3 "$(QFUSE_SOURCE_DIR)/scripts/uninstall-qnx.py" "$(QFUSE_PORT_PREFIX)"
