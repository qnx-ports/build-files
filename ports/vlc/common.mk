####################==================##################################
ifndef QCONFIG     #  #### #  # #  #  # Last Modified 5/20/2025 
QCONFIG=qconfig.mk #  #  # ## #  #/   # 
endif              #  # #\ # ##  /#   # Made to be compatible with
include $(QCONFIG) #  ##\# #  # #  #  # <link?>
####################==================##################################

## Set up user-overridden variables
PREFIX 			    ?= /usr/local
QNX_PROJECT_ROOT    ?= $(PRODUCT_ROOT)/../../vlc_2
#FIX THIS FROM vlc_2 REVIEWERS THIS IS AN ERROR!!!

## Set up QNX recursive makefile specifics.
.PHONY: vlc_all install clean
ALL_DEPENDENCIES = vlc_all
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

##########Pre-Target Def############
include $(MKFILES_ROOT)/qtargets.mk
##########Post-Target Def###########

## Flag settings for qtargets and make
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl
CFLAGS  += -D_QNX_SOURCE -O3 -D_LARGEFILE64_SOURCE=1 \
		   -I$(INSTALL_ROOT)/$(PREFIX)/include -I$(QNX_TARGET)/$(PREFIX)/include \
		   -I$(QNX_TARGET)/usr/include -I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include \
		   -I$(QNX_TARGET)/usr/include/unicode

ifndef CPUDIR
$(error No CPU selection detected.)
else
$(info CPU detected as: $(CPUDIR))
endif

ifeq ($(CPUDIR), aarch64le)
PLATFORM=aarch64-unknown
V_OPT=gcc_ntoaarch64le
SOURCE_FOLDER_NAME=nto-aarch64-le
else ifeq ($(CPUDIR), x86_64)
PLATFORM=x86_64-pc
V_OPT=gcc_ntox86_64
SOURCE_FOLDER_NAME=nto-x86_64-o
else
$(error Not a supported CPU.)
endif

CONFIGURE_ENVS= CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT) -lsocket " \
				CXX="$(QNX_HOST)/usr/bin/q++ -V$(V_OPT)_cxx -lsocket " \
				CFLAGS="$(CFLAGS)" \
				PKG_CONFIG_PATH=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/

CONFIGURE_OPTS= --host=$(PLATFORM)-nto \
				--prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) \
				--enable-vdpau=no \
				--disable-lua \
				--disable-a52 \
				--disable-skins2 \
				--disable-avcodec \
				--disable-swscale \
				--disable-qt --disable-qtsvg --disable-qtdeclarative --disable-qtshadertools --disable-qtwayland

MAKE_OPTS= CFLAGS="$(CFLAGS)" 

# This just wraps the configuration available in the qnx port of VLC. it is purely for installation purposes (and to simplify RetroPie's process)
# In other words, please see those files to make actual changes.
vlc_all:
	@cd $(QNX_PROJECT_ROOT)/qnx && make install
	@mkdir -p staging/lib
	@mkdir -p staging/include
	@cp -r $(QNX_PROJECT_ROOT)/qnx/$(SOURCE_FOLDER_NAME)/install/lib/* staging/lib/
	@cp -r $(QNX_PROJECT_ROOT)/qnx/$(SOURCE_FOLDER_NAME)/install/include/* staging/include/


install: vlc_all
	@cp -r staging/* $(QNX_TARGET)/$(CPUDIR)/usr/local/

install_rpie: install
	@mkdir -p $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/
	@mkdir -p $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/include/
	@cp staging/lib/* $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/
	@cp staging/include/* $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/include/

clean:
	rm -rf staging
	cd $(QNX_PROJECT_ROOT)/qnx && make clean