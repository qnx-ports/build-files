ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=memory

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
MEMORY_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

MEMORY_VERSION = 0.7-3

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#set the following to FALSE if generating .pinfo files is causing problems
GENERATE_PINFO_FILES ?= TRUE

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = memory_all
.PHONY: memory_all install check clean

CFLAGS += $(FLAGS)
LDFLAGS += -Wl,--build-id=md5 -lc++ -lm

define PINFO
endef
PINFO_STATE=Experimental
USEFILE=

include $(MKFILES_ROOT)/qtargets.mk

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_LIBDIR=$(MEMORY_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib \
             -DCMAKE_INSTALL_PREFIX=$(MEMORY_INSTALL_ROOT)/$(CPUVARDIR)/usr \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DBUILD_SHARED_LIBS=1 \
             -DDOCTEST_USE_STD_HEADERS=ON

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
memory_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)/
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: memory_all
	@echo Installing...
	@cd build && make VERBOSE=1 install all $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -fr build

uninstall:
endif

#everything down below deals with the generation of the PINFO
#information for shared objects that is used by the QNX build
#infrastructure to embed metadata in the .so files, for example
#data and time, version number, description, etc. Metadata can
#be retrieved on the target by typing 'use -i <path to openblas .so file>'.
#this is optional: setting GENERATE_PINFO_FILES to FALSE will disable
#the insertion of metadata in .so files.
ifeq ($(GENERATE_PINFO_FILES), TRUE)
#the following rules are called by the cmake generated makefiles,
#in order to generate the .pinfo files for the shared libraries
%.so$(MEMORY_VERSION):
	$(ADD_PINFO)
	$(ADD_USAGE)

endif
