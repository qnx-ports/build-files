ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)



ALL_DEPENDENCIES = freeimage_all
.PHONY: freeimage_all install check clean

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

QNX_PROJECT_ROOT?=$(PRODUCT_ROOT)/../../FreeImage
PREFIX?="usr/local"

include $(MKFILES_ROOT)/qtargets.mk
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl

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
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
             -DBUILD_TESTS=OFF \

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)


ifndef NO_TARGET_OVERRIDE
freeimage_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

# @mkdir -p build
# @echo $(QNX_PROJECT_ROOT)
# @cd build && cp -r $(QNX_PROJECT_ROOT)/* .
# @cd build && PC_EXECPREFIX="$(QNX_TARGET)/$(CPUDIR)/$(PREFIX)" PC_PREFIX="$(QNX_TARGET)/$(PREFIX)" CC=$(CC) AR=$(AR) CXX=$(CXX) make -fMakefile.qnx $(MAKE_ARGS)

#somehow this works even without the explicit dependance on freeimage_all.
#assume its due to ALL_DEPENDENCIES
install check:
	@echo Installing...
	-cd build && make install $(MAKE_ARGS)
	-cd build && cp libfreeimage.so $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/libFreeImage.so
	-cd build && cp libfreeimage.so $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/libfreeimage-3.18.0.so
	-cp ../FreeImage.pc build/
	-sed -i 's,%CPU%,$(CPUVARDIR),' build/FreeImage.pc
# 	-cp build/FreeImage.pc $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/
# 	-cp build/FreeImage.pc $(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/freeimage.pc
	-mkdir -p $(INSTALL_ROOT)/$(PREFIX)/include/FreeImage/
	-cp $(INSTALL_ROOT)/$(PREFIX)/include/freeimage/* $(INSTALL_ROOT)/$(PREFIX)/include/FreeImage/
	@echo Done! Installed.

# Shortcut for RetroPie's build/install all script
install_rpie: install
	@mkdir -p $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/
	@cp build/*.so* $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/

clean:
	rm -rf build
endif