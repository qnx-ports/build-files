
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

######### Settable Env. Vars ##################
# Project Settings
NAME=OpenTTD
QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../../OpenTTD

# Installation Locations
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))
PREFIX ?= /usr/local

# CMake Settings
CMAKE_BUILD_TYPE ?= Release

######## Do Not Touch anything below here! ####
ALL_DEPENDENCIES = OpenTTD_all
.PHONY: OpenTTD_all clean

FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl, -lsocket -lpng -lregex -lz

###############################################
include $(MKFILES_ROOT)/qtargets.mk
###############################################
#### Determine host

## QNX 8.0.x
ifneq (,$(findstring 800,$(QNX_TARGET)))
ifneq (,$(findstring aarch64,$(CPUDIR)))
HOST_DETECT = aarch64-unknown-nto-qnx8.0.0
V_OPT=gcc_ntoaarch64le
endif
ifneq (,$(findstring x86_64,$(CPUDIR)))
HOST_DETECT = x86_64-pc-nto-qnx8.0.0
V_OPT=gcc_ntox86_64
endif
endif

## QNX 7.1.x
ifneq (,$(findstring 710,$(QNX_TARGET)))
ifneq (,$(findstring aarch64,$(CPUDIR)))
HOST_DETECT = aarch64-unknown-nto-qnx7.1.0
V_OPT=gcc_ntoaarch64le
endif
ifneq (,$(findstring x86_64,$(CPUDIR)))
HOST_DETECT = x86_64-pc-nto-qnx7.1.0
V_OPT=gcc_ntox86_64
endif
endif
###############################################

CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)
CMAKE_MODULE_PATH    := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake
CFLAGS               += $(FLAGS) -I$(INSTALL_ROOT)/$(PREFIX)/include -I$(QNX_TARGET)/$(PREFIX)/include 
# -I$(QNX_TARGET)/include

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_C_FLAGS="$(CFLAGS)" \
             -DCMAKE_CXX_FLAGS="$(CFLAGS) -isystem $(QNX_TARGET)/usr/include/c++/v1/ -V$(V_OPT)" \
             -DCMAKE_EXE_LINKER_FLAGS="$(LDFLAGS)" \
			 -DCMAKE_SO_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPU=$(CPU) \
             -DOPTION_TOOLS_ONLY=OFF \
             -DCMAKE_BUILD_TYPE=RelWithdebInfo \
             -DHOST_BINARY_DIR=../build_native  
 #            -DOPTION_DEDICATED=ON

CMAKE_ARGS_TOOLS = -DCMAKE_INSTALL_PREFIX="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)" \
                   -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
                   -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
                   -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
	               -DCMAKE_BUILD_TYPE=RelWithdebInfo \
                   -DOPTION_TOOLS_ONLY=ON 

MAKE_ARGS  ?= -j $(firstword $(JLEVEL) 1)

OpenTTD_all:
	@mkdir -p $(QNX_PROJECT_ROOT)/build_native
	@cd $(QNX_PROJECT_ROOT)/build_native && PKG_CONFIG_PATH=${INSTALL_ROOT_nto}/${cpudir}/usr/lib/pkgconfig:${INSTALL_ROOT_nto}/${cpudir}/usr/local/lib/pkgconfig cmake $(CMAKE_ARGS_TOOLS) $(QNX_PROJECT_ROOT)
	@cd $(QNX_PROJECT_ROOT)/build_native && PKG_CONFIG_PATH=${INSTALL_ROOT_nto}/${cpudir}/usr/lib/pkgconfig:${INSTALL_ROOT_nto}/${cpudir}/usr/local/lib/pkgconfig make VERBOSE=1 $(MAKE_ARGS)
	@mkdir -p $(QNX_PROJECT_ROOT)/build
	@cd $(QNX_PROJECT_ROOT)/build && PKG_CONFIG_PATH=${INSTALL_ROOT_nto}/${cpudir}/usr/lib/pkgconfig:${INSTALL_ROOT_nto}/${cpudir}/usr/local/lib/pkgconfig cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd $(QNX_PROJECT_ROOT)/build && PKG_CONFIG_PATH=${INSTALL_ROOT_nto}/${cpudir}/usr/lib/pkgconfig:${INSTALL_ROOT_nto}/${cpudir}/usr/local/lib/pkgconfig make VERBOSE=1 $(MAKE_ARGS)
	@mkdir -p build
	@mkdir -p build_native
	@cp -r $(QNX_PROJECT_ROOT)/build/* build/
	@cp -r $(QNX_PROJECT_ROOT)/build_native/* build_native/

staged: OpenTTD_all
	@mkdir -p staging/lib
	@cp -r build/ai staging/
	@cp -r build/baseset staging/
	@cp -r build/game staging/
	@cp -r build/generated staging/
	@cp -r build/lang staging/
	@cp -r build/media staging/
	@cp -r build/regression staging/
	@cp  build/openttd staging/openttd
	@cp  build/openttd staging/openttd.ttd
	@cp  build/openttd_test staging/
	@cp  ../startopenttd.sh staging/
	@cp  ../startserver.sh staging/
	@cp  $(QNX_TARGET)/$(CPUVARDIR)/usr/lib/libc++* staging/lib
	-cp $(QNX_TARGET)/$(CPUVARDIR)/usr/lib/*SDL* staging/lib
	-cp $(QNX_TARGET)/$(CPUVARDIR)/usr/local/lib/*SDL* staging/lib
# Yes, this is needed for the quick start image. Unfortunately it seems to have a slightly outdated std::chrono implementation.
# Users will need to set their LD_LIBRARY_PATH accordingly or use the provided startopenttd.sh script
#Optionally: Grab Graphics
#	@curl https://cdn.openttd.org/opengfx-releases/7.1/opengfx-7.1-all.zip --output opengfx-7.1-all.zip
# 	@unzip opengfx-7.1-all.zip
# 	@cp opengfx-7.1.tar staging/baseset/

install_rpie: staged
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/OpenTTD
	@cp -r staging/* $(PRODUCT_ROOT)/staging/$(CPUDIR)/OpenTTD

clean:
	@rm -rf $(QNX_PROJECT_ROOT)/build
	@rm -rf $(QNX_PROJECT_ROOT)/build_native
	@rm -rf build
	@rm -rf build_native
	@rm -rf staging