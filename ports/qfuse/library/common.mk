# SPDX-License-Identifier: MIT
include $(dir $(lastword $(MAKEFILE_LIST)))../common.mk
NAME := fuse3
SRCS := core.c qnx_backend.c fuse_opt.c fuse_log.c
INSTALLDIR := $(PREFIX)/lib
include $(MKFILES_ROOT)/qtargets.mk
include $(QFUSE_PORT_DIR)/tools.mk
