####################==================#######################################
ifndef QCONFIG     #  #### #  # #  #  # Last Modified 2/21/2025 
QCONFIG=qconfig.mk #  #  # ## #  #/   # 
endif              #  # #\ # ##  /#   # Made to be compatible with
include $(QCONFIG) #  ##\# #  # #  #  # https://github.com/memononen/nanosvg
####################==================#######################################

## Set up user-overridden variables
PREFIX 			 ?= /usr/local						# part of the install path in $QNX_TARGET
QNX_PROJECT_ROOT ?=	$(PRODUCT_ROOT)/../../nanosvg	# path to the nanosvg source code

## Set up QNX recursive makefile specifics.
.PHONY: nanosvg_all install clean
ALL_DEPENDENCIES = nanosvg_all
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

## Flag settings for qtargets and cmake
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl

###################################
include $(MKFILES_ROOT)/qtargets.mk
###################################

## Setup paths for CMAKE find_*
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)
CMAKE_MODULE_PATH 	 := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake
CFLAGS 				 += -I$(INSTALL_ROOT)/$(PREFIX)/include -I$(QNX_TARGET)/$(PREFIX)/include
# $(QNX_TARGET) contains architecture-agnostics (i.e. headers, non-compiled) from SDP
# $(QNX_TARGET)/$(CPUVARDIR) contains architecture specific from SDP
# $(INSTALL_ROOT)/$(CPUVARDIR) contains built and installed packages
# CMAKE_MODULE_PATH and CFLAGS are set to find relevent include and cmake folders in these places.

## CMAKE Arguments
CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPU=$(CPU) \

nanosvg_all:
	@echo "Building..."
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make

install: nanosvg_all
	@echo "Installing..."
	@cd build && make install

clean:
	rm -rf build