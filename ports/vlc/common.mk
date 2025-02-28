####################==================##################################
ifndef QCONFIG     #  #### #  # #  #  # Last Modified 2/26/2025 
QCONFIG=qconfig.mk #  #  # ## #  #/   # 
endif              #  # #\ # ##  /#   # Made to be compatible with
include $(QCONFIG) #  ##\# #  # #  #  # https://github.com/qnx-ports/vlc
####################==================##################################

## Set up user-overridden variables
PREFIX 			    ?= /usr/local
QNX_PROJECT_ROOT    ?= $(PRODUCT_ROOT)/../../vlc

## Set up QNX recursive makefile specifics.
.PHONY: vlc_all install clean
ALL_DEPENDENCIES = vlc_all
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

## Flag settings for qtargets and make
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl 
CFLAGS  += -std=gnu11 -D_QNX_SOURCE -D_LARGEFILE64_SOURCE=1

##########Pre-Target Def############
include $(MKFILES_ROOT)/qtargets.mk
##########Post-Target Def###########

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

CONFIGURE_ENVS= CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT) -lsocket " \
				CXX="$(QNX_HOST)/usr/bin/q++ -V$(V_OPT)_cxx -lsocket " \
				CFLAGS="$(CFLAGS)" \
				PKG_CONFIG_PATH=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/ \
				PKG_CONGIG_LIBDIR=""

CONFIGURE_OPTS= --host=$(PLATFORM)-nto \
				--prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) \
				--enable-vdpau=no \
				--disable-qt \
				--disable-lua 

MAKE_OPTS= 

# CC="$QNX_HOST/usr/bin/qcc -Vgcc_ntoaarch64le -lsocket" CXX="$QNX_HOST/usr/bin/q++ -Vgcc_ntoaarch64le_cxx -lsocket" 
#CFLAGS="-std=gnu11 -D_QNX_SOURCE" ./configure --disable-lua --disable-qt --enable-vdpau=no --host=aarch64-unknown-nto

vlc_all:
	@cd $(QNX_PROJECT_ROOT) && if [ ! -f "configure" ]; then ./bootstrap; fi
	@mkdir -p build
	@cd $(QNX_PROJECT_ROOT) && $(CONFIGURE_ENVS) ./configure $(CONFIGURE_OPTS)
	@make -C $(QNX_PROJECT_ROOT) clean
	@make -C $(QNX_PROJECT_ROOT) $(MAKE_OPTS)


install:
	@echo "TODO - not implemented"

clean:
	rm -rf build
	@make -C$(QNX_PROJECT_ROOT) clean