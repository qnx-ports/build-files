ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

#where to install cJSON:
#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
CJSON_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#set the following to FALSE if generating .pinfo files is causing problems
GENERATE_PINFO_FILES ?= TRUE

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = cjson_all
.PHONY: cjson_all

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_INCLUDEDIR=$(CJSON_INSTALL_ROOT)/usr/include \
             -DCMAKE_INSTALL_PREFIX=$(CJSON_INSTALL_ROOT)/$(CPUVARDIR)/usr \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_MODULE_PATH=$(PROJECT_ROOT) \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DGCC_VER=${GCC_VER}

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 4)

include $(MKFILES_ROOT)/qtargets.mk


ifndef NO_TARGET_OVERRIDE
cjson_all:
	@mkdir -p build
	cd build && cmake $(CMAKE_ARGS) ../../../../../
	cd build && make all $(MAKE_ARGS) VERBOSE=1

install: cjson_all
	@cd build && make install $(MAKE_ARGS)

clean iclean spotless:
	rm -fr build

cuninstall uninstall:
	
endif
