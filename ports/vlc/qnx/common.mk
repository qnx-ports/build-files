# Define some error strings that will explain why things fail
# when something has gone wrong in the host side of the buid process.
define error_not_bootstrapped
ERROR
VLC's build has not been bootstrap'ed yet.

This should happen automatically if all targets are being built.
But if you are building a specific target, for example aarch64, you might
have to do it manually by building the linux-x86_64 tree first.

endef
define error_not_fetched
ERROR
VLC's contrib packages have not been fetched yet.

This should happen automatically if all targets are being built.
But if you are building a specific target, for example aarch64, you might
have to do it manually by building the linux-x86_64 tree first.

endef
define error_no_host_protoc
ERROR
Host version of protoc has not been built yet.

This should happen automatically if all targets are being built.
But if you are building a specific target, for example aarch64, you might
have to do it manually by building the linux-x86_64 tree first.

endef

ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=vlc

VLC_VERSION = 3.0.21

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../vlc

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT := $(INSTALL_ROOT_$(OS))

#A prefix path to use **on the target**. This is
#different from INSTALL_ROOT, which refers to a
#installation destination **on the host machine**.
#This prefix path may be exposed to the source code,
#the linker, or package discovery config files (.pc,
#CMake config modules, etc.). Default is /usr/local
PREFIX ?= /usr/local

#choose release or debug
VLC_BUILD_TYPE ?= release
ifeq "$(VLC_BUILD_TYPE)" "debug"
  VLC_C_FLAGS := -g 
  VLC_CFG_ARGS := '--enable-debug'
endif

VLC_C_FLAGS += -Dqt=disabled -Dskins2=disabled

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = vlc_all
.PHONY: vlc_all

include $(MKFILES_ROOT)/qtargets.mk

# Add choice to build and install tests
#BUILD_TESTING ?= true

# Need to discover the host triplet for cross compilation
# First find the actual compiler used.
VLC_HOST := $(notdir $(realpath $(firstword $(CC_nto_$(CPU)_gcc))))
# Then remove the -gcc-<some_version> part. Easiest way to do that is
# to replace -gcc- with a space and then just grab the first word
VLC_HOST := $(firstword $(subst -gcc-, ,$(VLC_HOST)))

FULL_CPU := $(CPU)
ifeq "$(FULL_CPU)" "aarch64"
  FULL_CPU := $(FULL_CPU)le
endif
VLC_CPU_TARGET := gcc_nto$(FULL_CPU)

# VLC's build will locate dependencies via package-config files. Tell it where
# to look for them. By default, that will be the stage (if there is one) and
# the actual SDP install.
PKG_CONFIG_LIBDIR ?= $(INSTALL_ROOT)/$(FULL_CPU)/lib/pkgconfig:$(QNX_TARGET)/$(FULL_CPU)/usr/lib/pkgconfig

# Need a host verison of protoc. One should have been built as part
# of the bootstrapping process.
#HOST_PROTOC := $(QNX_PROJECT_ROOT)/qnx/linux-x86_64/protoc

# Additional environment variables when building the contrib packages.
VLC_CONTRIB_ENV := PROTOC=$(HOST_PROTOC)

# Arguments to VLC's contrib build bootstrap/configuration.
VLC_CONTRIB_ARGS := --host=$(VLC_HOST) \
		    --disable-xcb \
			--disable-lua \
			--disable-a52 \
			--disable-skins2 \
			--disable-avcodec \
			--disable-swscale \
			--disable-alsa \
			--disable-qt --disable-qtsvg --disable-qtdeclarative --disable-qtshadertools --disable-qtwayland 

# Environment variables to VLC's build configuration
#
# The EGL_CFLAGS & GLES2_CFLAGS arguments are to prevent VLC from
# using pkg-config files to locate EGL/GLES2 support. Those pkg-config
# files don't exist in QNX's SDP.
VLC_CFG_ENV := CFLAGS="-D_QNX_SOURCE ${VLC_C_FLAGS}" \
	       CXXFLAGS="-D_QNX_SOURCE ${VLC_C_FLAGS}" \
	       CC="qcc -V${VLC_CPU_TARGET}" \
	       CXX="q++ -V${VLC_CPU_TARGET}" \
	       EGL_CFLAGS="-DDUMMY_EGL_CFLAG" \
	       EGL_LIBS="-lEGL -lscreen" \
	       GLES2_CFLAGS="-DDUMMY_GLES2_CFLAG" \
	       GLES2_LIBS="-lEGL -lGLESv2 -lscreen" \
	       PKG_CONFIG_LIBDIR="$(PKG_CONFIG_LIBDIR)"
# 	       PROTOC=$(HOST_PROTOC) \

# Arguments to VLC's build configuration
VLC_CFG_ARGS += --host=${VLC_HOST} \
		--build=i386-linux \
		--disable-alsa \
		--disable-a52 \
		--disable-xcb \
		--enable-gles2 \
		--with-contrib=$(CURDIR)/${VLC_HOST} \
		--prefix=$(CURDIR)/install \
		--disable-lua \
		--disable-a52 \
		--disable-skins2 \
		--disable-avcodec \
		--disable-swscale \
		--disable-qt --disable-qtsvg --disable-qtdeclarative --disable-qtshadertools --disable-qtwayland --disable-alsa

VLC_MAKE_ENV := LIBS_qt="-lfreetype -lz -lxml2 -llzma"

# Currently x86_64 does not support audio/ALSA
ifneq "$(CPU)" "x86_64"
    VLC_CFG_ARGS += --enable-alsa
else
	VLC_CFG_ARGS += --disable-alsa
endif

# Target to check that all the host side prerequisites are satisified.
# See qnx/linux-x86_64/Makefile for details.
.prereq_check:
ifeq ($(wildcard $(QNX_PROJECT_ROOT)/qnx/linux-x86_64/.bootstrap),)
	$(error $(error_not_bootstrapped))
endif
ifeq ($(wildcard $(QNX_PROJECT_ROOT)/qnx/linux-x86_64/.fetched),)
	$(error $(error_not_fetched))
endif
	@touch .prereq_check

# ifeq ($(wildcard $(HOST_PROTOC)),)
# 	$(error $(error_no_host_protoc))
# endif

# Bootstrap the contrib's build to cross-compile for the target.
contrib/Makefile: .prereq_check
	@mkdir -p contrib
	@cd contrib && $(QNX_PROJECT_ROOT)/contrib/bootstrap $(VLC_CONTRIB_ARGS)

# Build the contrib packages for the target.
.built_contrib: .prereq_check contrib/Makefile $(HOST_PROTOC)
	@cd contrib && $(VLC_CONTRIB_ENV) make
	@touch .built_contrib

#NOTE: THESE OPTS ARE NOT
# Configure VLC's build system to cross-compile for the target.
build/Makefile: .prereq_check .built_contrib $(HOST_PROTOC)
	@mkdir -p build
	@cd build && $(VLC_CFG_ENV) $(QNX_PROJECT_ROOT)/configure $(VLC_CFG_ARGS) --disable-alsa --enable-alsa=no --enable-vdpau=no \
				--disable-lua \
				--disable-a52 \
				--disable-skins2 \
				--disable-avcodec \
				--disable-swscale \
				--disable-qt --disable-chromecast --disable-alsa

# Build VLC for the target.
vlc_all: .prereq_check build/Makefile $(HOST_PROTOC)
	@cd build && $(VLC_MAKE_ENV) make

# Install VLC for the target.
install: vlc_all
	@cd build && make install 
	@cp $(QNX_PROJECT_ROOT)/qnx/vlc.sh $(CURDIR)/install/bin

vlc_clean:
	@rm -rf $(VLC_HOST)
	@rm -rf bin
	@rm -rf build
	@rm -rf contrib
	@rm -rf .built_contrib
	@rm -rf install
	@rm -rf .prereq_check
clean: vlc_clean
spotless: vlc_clean

