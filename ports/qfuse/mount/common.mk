# SPDX-License-Identifier: MIT
include $(dir $(lastword $(MAKEFILE_LIST)))../common.mk
NAME := qfuse-mount
SRCS := mount.c
INSTALLDIR := $(PREFIX)/bin
include $(MKFILES_ROOT)/qtargets.mk
include $(QFUSE_PORT_DIR)/tools.mk
