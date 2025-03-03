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

#### Set up default target (QNX-specific) 
#Overriding `all` bypasses built-in qnx stuff.
ALL_DEPENDENCIES = RetroArch_all
.PHONY: RetroArch_all install check clean test clean-staging assets

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
				   PKG_CONFIG_PATH="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig"

# Yes, these are correct. It is a very strange "configure" script - seems to be handmade.
CONFIGURE_OPTS= --host="$(PLATFORM)-nto-qnx8.0.0-"\
				--build="$(PLATFORM)-nto-qnx8.0.0-" \
				--prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib \
				--bindir=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin \
              	--sysconfdir=$(QNX_TARGET)/etc

#################################################################################
include $(MKFILES_ROOT)/qtargets.mk
#################################################################################

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1) 

ifndef NO_TARGET_OVERRIDE
RetroArch_all:
	@mkdir -p build
	@cd build && cp -r $(DIST_BASE)/* .
	@echo $(CONFIGURE_OPTS)
	@cd build && $(CONFIGURE_PREOPTS) ./configure $(CONFIGURE_OPTS)
	@cd build && $(CONFIGURE_PREOPTS) make VERBOSE=1 all $(MAKE_ARGS) 
#	@cd build && sed -i s/materialui_menu_color_theme = ./materialui_menu_color_theme = 9/ 

install check: RetroArch_all assets info
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/rarch-shared/content/
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/lib/
	-cp $(QNX_TARGET)/$(CPUVARDIR)/usr/lib/libxkbcommon* $(PRODUCT_ROOT)/staging/$(CPUDIR)/lib/
	@cp build/retroarch $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/ 
	@cp ../startup.sh $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/
	-chmod 764 $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/startup.sh
	@echo Done.

info:
	@echo Checking for folder...
	@if [ -d "$(DIST_BASE)/../libretro-core-info" ]; then echo "Found!"; else echo "libretro-core-info not found. Exiting"; exit 1; fi 
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/info/
	@echo "Copying core info over..." && cp $(DIST_BASE)/../libretro-core-info/* $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/info/
	@echo "Copied info files!"

assets:
	@echo Checking for folder...
	@if [ -d "$(DIST_BASE)/../retroarch-assets" ]; then echo "Found!"; else echo "retroarch-assets not found. Exiting"; exit 1; fi 
	@echo "Installing Assets..."
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Assets from multiple sources, in /src
	@echo "Assorted Core Assets..." && cp -r $(DIST_BASE)/../retroarch-assets/src $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Default supported menus
	@echo "Ozone Menu" && cp -r $(DIST_BASE)/../retroarch-assets/ozone $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "GLUI Menu..." && cp -r $(DIST_BASE)/../retroarch-assets/glui $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "RGUI Menu..." && cp -r $(DIST_BASE)/../retroarch-assets/rgui $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "XMB Menu..." && cp -r $(DIST_BASE)/../retroarch-assets/xmb $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "XMB Support Scripts" && cp -r $(DIST_BASE)/../retroarch-assets/scripts $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Additional Menu Themes
	@echo "'Automatic' Menu Theme..." && cp -r $(DIST_BASE)/../retroarch-assets/Automatic $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "'FlatUX' Menu Theme..." && cp -r $(DIST_BASE)/../retroarch-assets/FlatUX $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "'FlatUX' Config..." && cp -r $(DIST_BASE)/../retroarch-assets/cfg $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "'Systematic' Menu Theme" && cp -r $(DIST_BASE)/../retroarch-assets/Systematic $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Assorted General Assets
	@echo "RetroArch Brand Assets..." && cp -r $(DIST_BASE)/../retroarch-assets/branding $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "Image Devtools..." && cp -r $(DIST_BASE)/../retroarch-assets/devtools $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "Fonts..." && cp -r $(DIST_BASE)/../retroarch-assets/fonts $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "Fallback Fonts..." && cp -r $(DIST_BASE)/../retroarch-assets/pkg $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Backgrounds/Wallpapers
	@echo "Wallpapers..." && cp -r $(DIST_BASE)/../retroarch-assets/wallpapers $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "3DS/DualScreen Backgrounds..." && cp -r $(DIST_BASE)/../retroarch-assets/ctr $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Platform Specifics
	@echo "'nxrgui' Platform Assets" && cp -r $(DIST_BASE)/../retroarch-assets/nxrgui $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	@echo "Switch Icons..." && cp -r $(DIST_BASE)/../retroarch-assets/switch $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
#Audio
	@echo "Audio..." && cp -r $(DIST_BASE)/../retroarch-assets/sounds $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch/data/assets/
	
	@echo "Copied required assets!"

clean iclean spotless:
	@rm -rf build

clean-staging: clean
	@rm -rf $(PRODUCT_ROOT)/staging/$(CPUDIR)/retroarch

endif
