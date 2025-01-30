ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)


include $(MKFILES_ROOT)/qmacros.mk

NAME=RetroArch

DIST_BASE=$(PRODUCT_ROOT)/../../../RetroArch
ifdef QNX_PROJECT_ROOT
DIST_BASE=$(QNX_PROJECT_ROOT)
endif

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

ifndef CPUDIR
$(error No CPU selection detected.)
else
$(info CPU detected as: $(CPUDIR))
endif

ifeq ($(CPUDIR), aarch64le)
PLATFORM=aarch64-unknown
V_OPT=gcc_ntoaarch64le
else ifeq ($(CPUDIR), x86_64)
PLATFORM=x86_64-pc
V_OPT=gcc_ntox86_64
else
$(error Not a supported CPU.)
endif

CONFIGURE_PREOPTS= CC=$(QNX_HOST)/usr/bin/qcc \
				   CXX=$(QNX_HOST)/usr/bin/q++ \
				   LD=$(PLATFORM)-nto-qnx8.0.0-ld \
				   CFLAGS="-D_QNX_SOURCE -std=c17 -V$(V_OPT) $(CFLAGS)"\
				   CXXFLAGS="-D_QNX_SOURCE -std=c++17 -V$(V_OPT)_cxx -Wno-deprecated-definitions $(CXXFLAGS)"\
				   LDFLAGS=$(LDFLAGS) \
				   CPPFLAGS="-D_QNX_SOURCE $(CPPFLAGS)"\
				   PKG_CONFIG_LIBDIR="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig" \
				   PKG_CONFIG_PATH="pkg-config"

# Yes, these are correct. It is a very strange "configure" script - seems to be handmade.
CONFIGURE_OPTS= --host="$(PLATFORM)-nto-qnx8.0.0-"\
				--build="$(PLATFORM)-nto-qnx8.0.0-" \
				--prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib \
				--bindir=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin \
              	--sysconfdir=$(QNX_TARGET)/etc

include $(MKFILES_ROOT)/qtargets.mk

#override 'all' target to bypass the default QNX build system
.PHONY: RetroArch_all install check clean
.DEFAULT_GOAL := RetroArch_all

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1) 

ifndef NO_TARGET_OVERRIDE
RetroArch_all:
	@mkdir -p build
	@cd build && cp -r $(DIST_BASE)/* .
	@echo $(CONFIGURE_OPTS)
	@cd build && $(CONFIGURE_PREOPTS) ./configure $(CONFIGURE_OPTS)
	@cd build && $(CONFIGURE_PREOPTS) make VERBOSE=1 all $(MAKE_ARGS) 

install check: RetroArch_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build
endif
