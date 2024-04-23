ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../

#where to install mosquitto:
#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
MOSQUITTO_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#set the following to FALSE if generating .pinfo files is causing problems
GENERATE_PINFO_FILES ?= TRUE

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = mosquitto_all
.PHONY: mosquitto_all

FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -lsocket

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX=$(MOSQUITTO_INSTALL_ROOT) \
             -DMOSQUITTO_EXTERNAL_DEPS_INSTALL=$(MOSQUITTO_EXTERNAL_DEPS_INSTALL) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_INSTALL_BINDIR=$(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/bin \
             -DCMAKE_INSTALL_INCLUDEDIR=$(MOSQUITTO_INSTALL_ROOT)/usr/include \
             -DCMAKE_INSTALL_LIBDIR=$(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/lib \
             -DCMAKE_INSTALL_SBINDIR=$(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/sbin \
             -DCMAKE_MODULE_PATH=$(PROJECT_ROOT) \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DGENERATE_PINFO_FILES=$(GENERATE_PINFO_FILES) \
             -DCXX_LIBTYPE=${CXX_LIBTYPE} \
             -DGCC_VER=${GCC_VER} \
             -DWITH_CJSON=OFF \
             -DDOCUMENTATION=OFF \
             -DBUILD_TESTING=ON

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 4)

define PINFO
endef
PINFO_STATE=Experimental
USEFILE=

include $(MKFILES_ROOT)/qtargets.mk

ifndef NO_TARGET_OVERRIDE
mosquitto_all:
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)
	@cp -r $(QNX_PROJECT_ROOT)/test ./build

test:
	@cd build && make install $(MAKE_ARGS)
	@cd build/test/broker/c && make -f Makefile.qnx clean && make -f Makefile.qnx $(MAKE_ARGS) TARGET=$(MOSQUITTO_INSTALL_ROOT) CPUVARDIR=$(CPUVARDIR)
	@cd build/test/lib/c && make -f Makefile.qnx clean&& make -f Makefile.qnx $(MAKE_ARGS) TARGET=$(MOSQUITTO_INSTALL_ROOT) CPUVARDIR=$(CPUVARDIR)
	@cd build/test/lib/cpp && make -f Makefile.qnx clean && make -f Makefile.qnx $(MAKE_ARGS) TARGET=$(MOSQUITTO_INSTALL_ROOT) CPUVARDIR=$(CPUVARDIR)

install: mosquitto_all test
	@cd build && make install $(MAKE_ARGS)
	@mkdir -p $(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/bin/mqtt_tests/src
	@cp $(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/sbin/mosquitto $(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/bin/mqtt_tests/src
	@rsync -av --exclude=*/*.c --exclude=*/*.cpp --exclude=*/*.h --exclude=*/Makefile* --exclude=*/old --exclude=*/random --exclude=*/unit build/test $(MOSQUITTO_INSTALL_ROOT)/$(CPUVARDIR)/usr/bin/mqtt_tests/

clean iclean spotless:
	@rm -fr build

cuninstall uninstall:

endif

#everything down below deals with the generation of the PINFO
#information for shared objects that is used by the QNX build
#infrastructure to embed metadata in the .so files, for example
#data and time, version number, description, etc. Metadata can
#be retrieved on the target by typing 'use -i <path to mosquitto .so file>'.
#this is optional: setting GENERATE_PINFO_FILES to FALSE will disable
#the insertion of metadata in .so files.
ifeq ($(GENERATE_PINFO_FILES), TRUE)
#the following rules are called by the cmake generated makefiles,
#in order to generate the .pinfo files for the shared libraries
%.so.2.0.15:
	$(ADD_PINFO)
	$(ADD_USAGE)

endif
