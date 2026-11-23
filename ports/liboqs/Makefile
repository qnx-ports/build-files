# Top-level Makefile for liboqs QNX ports tree

RECURSE_DIMS := OS CPU VARIANT
LIST := $(RECURSE_DIMS)

RECURSE_MAKEFILE ?= recurse.mk
ifdef QCONFIG
RECURSE_BASE_DIR := $(dir $(QCONFIG))
else
RECURSE_BASE_DIR :=
endif
include $(RECURSE_BASE_DIR)$(RECURSE_MAKEFILE)

# Job count extraction from MAKEFLAGS
LIBOQS_JLEVEL ?= $(subst -j,,$(filter -j%,$(MAKEFLAGS)))
