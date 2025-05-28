####################==================##################################
ifndef QCONFIG     #  #### #  # #  #  # Last Modified 2/21/2025 
QCONFIG=qconfig.mk #  #  # ## #  #/   # 
endif              #  # #\ # ##  /#   # Made to be compatible with
include $(QCONFIG) #  ##\# #  # #  #  # https://github.com/zeux/pugixml
####################==================##################################

## Set up user-overridden variables
PREFIX 			    ?= usr/local
QNX_PROJECT_ROOT    ?= $(PRODUCT_ROOT)/../../pugixml
PUGIXML_BUILD_TESTS ?= "OFF"

## Set up QNX recursive makefile specifics.
.PHONY: pugixml_all install clean
ALL_DEPENDENCIES = pugixml_all
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

## Flag settings for qtargets and cmake
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl

###################################
include $(MKFILES_ROOT)/qtargets.mk
###################################

## Setup paths for CMAKE find_*
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)
CMAKE_MODULE_PATH    := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake
# $(QNX_TARGET) contains architecture-agnostics (i.e. headers, non-compiled) from SDP
# $(QNX_TARGET)/$(CPUVARDIR) contains architecture specific from SDP
# $(INSTALL_ROOT)/$(CPUVARDIR) contains built and installed packages
# CMAKE_MODULE_PATH and CFLAGS are set to find relevent include and cmake folders in these places.

## CMAKE Arguments
CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_PROJECT_INCLUDE=$(PROJECT_ROOT)/project_hooks.cmake \
             -DCMAKE_INSTALL_PREFIX="$(INSTALL_ROOT)" \
             -DCMAKE_INSTALL_LIBDIR="$(CPUVARDIR)/$(PREFIX)/lib" \
             -DCMAKE_INSTALL_BINDIR="$(CPUVARDIR)/$(PREFIX)/bin" \
             -DCMAKE_INSTALL_INCLUDEDIR="$(PREFIX)/include" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPU=$(CPU) \
             -DBUILD_SHARED_LIBS=ON \
             -DPUGIXML_BUILD_TESTS=$(PUGIXML_BUILD_TESTS) \

pugixml_all:
	@echo "Building..."
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make

ifeq ($(PUGIXML_BUILD_TESTS),ON)
install: pugixml_all
	@echo "Installing..."
	@cd build && make install
	@mkdir -p ../staging/$(CPUDIR)/lib
	@cp build/*.so* ../staging/$(CPUDIR)/lib
	@cp build/pugixml-check ../staging/$(CPUDIR)/
	@echo Copying test data from $(QNX_PROJECT_ROOT)/tests
	@cp -r $(QNX_PROJECT_ROOT)/tests ../staging/$(CPUDIR)/
else
install: pugixml_all
	@echo "Installing..."
	@cd build && make install
endif

# Shortcut for RetroPie's build/install all script
install_rpie: install
	@mkdir -p $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/
	@cp build/*.so* $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/

clean:
	-rm -rf build
	-rm -rf ../staging