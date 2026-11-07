# SPDX-License-Identifier: MIT
QFUSE_PORT_DIR ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
QNX_PROJECT_ROOT ?= $(abspath $(QFUSE_PORT_DIR)/../../../qfuse)
QFUSE_GENERATED := $(QFUSE_PORT_DIR)/build/generated
PREFIX ?= /usr/local
USEFILE :=
CCFLAGS += -std=c11 -D_QNX_SOURCE -D_FILE_OFFSET_BITS=64 -g -O1
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/src $(QFUSE_GENERATED) $(QNX_PROJECT_ROOT)/.cache/libfuse/lib
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/include $(QNX_PROJECT_ROOT)/.cache/libfuse/include $(QFUSE_GENERATED)
