include ../../common.mk

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/tests

NAME := muslflt_tests
INSTALLDIR := $(PREFIX)/bin

include $(MKFILES_ROOT)/qtargets.mk
