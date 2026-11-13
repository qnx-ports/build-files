# SPDX-License-Identifier: MIT
ifndef QFUSE_PORT_DIR
QFUSE_PORT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
endif
ifndef QFUSE_NATIVE_STAGE
QFUSE_NATIVE_STAGE := $(if $(strip $(INSTALL_ROOT_nto)),$(abspath $(INSTALL_ROOT_nto)),$(QFUSE_PORT_DIR)/stage)
endif
ifndef QFUSE_NATIVE_PREFIX
QFUSE_NATIVE_PREFIX := $(if $(strip $(PREFIX)),$(PREFIX),/usr/local)
endif
override INSTALL_ROOT_nto := $(QFUSE_NATIVE_STAGE)
override PREFIX := $(QFUSE_NATIVE_PREFIX)
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
ifneq ($(INSTALL_ROOT_nto),$(QFUSE_NATIVE_STAGE))
$(error SDK configuration changed the private staging root)
endif
ifneq ($(strip $(QNX_TARGET)),)
ifneq ($(filter $(abspath $(QNX_TARGET))%,$(abspath $(INSTALL_ROOT_nto))),)
$(error INSTALL_ROOT_nto must stay outside the licensed SDP)
endif
endif
QNX_PROJECT_ROOT ?= $(abspath $(QFUSE_PORT_DIR)/../../../qfuse)
QFUSE_GENERATED := $(QFUSE_PORT_DIR)/build/generated
PREFIX ?= /usr/local
USEFILE :=
CCFLAGS += -std=c11 -D_QNX_SOURCE -D_FILE_OFFSET_BITS=64 -g -O1
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/src $(QFUSE_GENERATED) $(QNX_PROJECT_ROOT)/.cache/libfuse/lib
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/include $(QNX_PROJECT_ROOT)/.cache/libfuse/include $(QFUSE_GENERATED)
