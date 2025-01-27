ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=fribidi

FRIBIDI_VERSION = 2.3.0

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#This prefix path may be exposed to the source code,
#the linker, or package discovery config files (.pc,
#CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -Wl,--allow-shlib-undefined

include $(MKFILES_ROOT)/qtargets.mk

# Add choice to build and install tests
BUILD_TESTING ?= ON
INSTALL_TESTS ?= ON

ifndef NO_TARGET_OVERRIDE
$(NAME)_all:
	@mkdir -p build

install check: $(NAME)_all
	@echo Installing...
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
endif
