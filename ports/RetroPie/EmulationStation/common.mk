ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)


NAME=EmulationStation

DIST_BASE=$(PRODUCT_ROOT)/../../../EmulationStation
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
PREFIX ?= usr/local

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = EmulationStation_all
.PHONY: EmulationStation_all install check clean

FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl

include $(MKFILES_ROOT)/qtargets.mk

#Search paths for all of CMake's find_* functions --
#headers, libraries, etc.
#
#$(QNX_TARGET): for architecture-agnostic files shipped with SDP (e.g. headers)
#$(QNX_TARGET)/$(CPUVARDIR): for architecture-specific files in SDP
#$(INSTALL_ROOT)/$(CPUVARDIR): any packages that may have been installed in the staging area
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)

#Path to CMake modules; These are CMake files installed by other packages
#for downstreams to discover them automatically. We support discovering
#CMake-based packages from inside SDP or in the staging area.
#Note that CMake modules can automatically detect the prefix they are
#installed in.
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

#Headers from INSTALL_ROOT need to be made available by default
#because CMake and pkg-config do not necessary add it automatically
#if the include path is "default"
CFLAGS +=   -I$(INSTALL_ROOT)/$(PREFIX)/include -I$(QNX_TARGET)/$(PREFIX)/include

# Add the line below
CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX="$(INSTALL_ROOT)" \
             -DCMAKE_INSTALL_LIBDIR="$(CPUVARDIR)/$(PREFIX)/lib" \
             -DCMAKE_INSTALL_BINDIR="$(CPUVARDIR)/$(PREFIX)/bin" \
             -DCMAKE_INSTALL_INCLUDEDIR="$(PREFIX)/include" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
             -DCPU=$(CPU) \
             -DGLES=ON \
             -DUSE_MESA_GLES=ON \
             -DGLSystem:STRING="$(QNX_TARGET)/$(CPUDIR)/usr/lib/graphics/rpi4-drm/libGLESv2-mesa.so" \
             -DSDL2_LIBRARY="$(QNX_TARGET)/$(CPUDIR)/$(PREFIX)/lib/libSDL2.so" \
             -DSDL2_PATH="$(QNX_TARGET)/$(CPUDIR)/$(PREFIX)/lib/libSDL2.so" \
             -DSDL2_INCLUDE_DIR="$(QNX_TARGET)/$(CPUDIR)/$(PREFIX)/include/SDL" \
             -DSDL2MAIN_LIBRARY="$(QNX_TARGET)/$(CPUDIR)/$(PREFIX)/lib/libSDL2main.a" \
             -DSDL2_NO_DEFAULT_PATH:BOOL=ON \
             -DPKG_CONFIG_EXECUTABLE="/usr/bin/pkgconf"
             

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

MAKE_PREARGS = PKG_CONFIG_PATH=$(QNX_TARGET)/$(CPUDIR)/$(PREFIX)/lib/pkgconfig \
               SDL2DIR=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) 

ifndef NO_TARGET_OVERRIDE
EmulationStation_all:
	@mkdir -p build/output
	@cd build && $(MAKE_PREARGS) cmake $(CMAKE_ARGS) $(DIST_BASE)
	@cd build && $(MAKE_PREARGS) make VERBOSE=1 all $(MAKE_ARGS)
	@cd build && cp $(DIST_BASE)/emulationstation output/
	@cd build && cp $(DIST_BASE)/*.a output/



#TODO: Install to staging/$CPUDIR/
#NOTE: may need to mess w retroarch locs :(
install check: EmulationStation_all
	@echo Installing...
	@cd build && $(MAKE_PREARGS) make VERBOSE=1 install $(MAKE_ARGS)
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/lib/
	@cp build/output/emulationstation $(PRODUCT_ROOT)/staging/$(CPUDIR)/
	@cp build/output/*.a $(PRODUCT_ROOT)/staging/$(CPUDIR)/lib/
	@cp ../startup.sh $(PRODUCT_ROOT)/staging/$(CPUDIR)/
	@cp -r $(DIST_BASE)/resources $(PRODUCT_ROOT)/staging/$(CPUDIR)/
	@echo Done.

clean iclean spotless:
	rm -rf build
endif