ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

PREFIX ?= usr/local
CCFLAGS := -Wno-parentheses -Werror=implicit-function-declaration -Wno-unused-but-set-variable
USEFILE :=

# Include all common (library) source files
# This can only be expanded after including qtargets.mk, hence = instead of :=
EXTRA_SRCVPATH = $(QNX_PROJECT_ROOT)/string \
                 $(QNX_PROJECT_ROOT)/complex \
                 $(QNX_PROJECT_ROOT)/fenv \
                 $(QNX_PROJECT_ROOT)/fenv/$(CPUVARDIR) \
                 $(QNX_PROJECT_ROOT)/math \
                 $(QNX_PROJECT_ROOT)/math/$(CPUVARDIR) \
                 $(QNX_PROJECT_ROOT)/qnx
