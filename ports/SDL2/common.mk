ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
##################################################

#### Project Options
NAME = SDL
QNX_PROJECT_ROOT ?= $(PROJECT_ROOT)/../../../SDL
PREFIX ?= /usr/local
CMAKE_BUILD_TYPE ?= Release
BUILD_TEST ?= false

#### Set up default target (QNX-specific) 
#Overriding `all` bypasses built-in qnx stuff.
ALL_DEPENDENCIES = SDL_all
.PHONY: SDL_all install check clean test

#### LD Flags and global C/C++ Flags
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl

#^ Setup pre-target decision. 
##################################################
include $(MKFILES_ROOT)/qtargets.mk
##################################################
#### Determine host

## QNX 8.0.x
ifneq (,$(findstring qnx800,$(QNX_TARGET)))
ifneq (,$(findstring aarch64,$(CPUDIR)))
HOST_DETECT = aarch64-unknown-nto-qnx8.0.0
V_OPT=gcc_ntoaarch64le
endif
ifneq (,$(findstring x86_64,$(CPUVDIR)))
HOST_DETECT = x86_64-pc-nto-qnx8.0.0
V_OPT=gcc_ntox86_64
endif
endif

## QNX 7.1.x
ifneq (,$(findstring qnx710,$(QNX_TARGET)))
ifneq (,$(findstring aarch64,$(CPUDIR)))
HOST_DETECT = aarch64-unknown-nto-qnx7.1.0
V_OPT=gcc_ntoaarch64le
endif
ifneq (,$(findstring x86_64,$(CPUDIR)))
HOST_DETECT = x86_64-pc-nto-qnx7.1.0
V_OPT=gcc_ntox86_64
endif
endif
##################################################

#v Stuff that may need to override target or depend on its definitions


#####NEEDED FOR HIGHER VERSIONS OF SDL
#### cmake Package Configuration
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

#### cmake Arguments
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
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
			 -DSDL_THREADS_ENABLED_BY_DEFAULT=ON \


#### Flags for g++/gcc C/CPP 
CFLAGS +=   -I$(INSTALL_ROOT)/$(PREFIX)/include \
			-I$(QNX_TARGET)/$(PREFIX)/include \
			$(FLAGS)

#### configure options
CONFIGURE_OPTS=	--prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) \
				--exec-prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) \
				--libdir=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib \
				--bindir=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin \
				--sysconfdir=$(QNX_TARGET)/etc \
				--oldincludedir=$(QNX_TARGET)/$(CPUVARDIR)/old/include 

CONFIGURE_PREOPTS= CC=$(QNX_HOST)/usr/bin/qcc \
				   CXX=$(QNX_HOST)/usr/bin/q++ \


#				   LD=$(HOST_DETECT)-ld \
				   CFLAGS="-D_QNX_SOURCE -std=c17 -V$(V_OPT) $(FLAGS)"\
				   CXXFLAGS="-D_QNX_SOURCE -std=c++17 -V$(V_OPT)_cxx -Wno-deprecated-definitions $(FLAGS)"\
				   LDFLAGS=$(LDFLAGS) \
				   CPPFLAGS="-D_QNX_SOURCE $(CPPFLAGS)"\

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1) VERBOSE=1

##################################################
#### Determine what version we are building for (assume 2.0.5)
ifndef SDL_VERSION


SDL_VERSION ?= 2.0.5
endif

##################################################
#### Make Targets || 2.0.5 ####
ifndef NO_TARGET_OVERRIDE
SDL_all:
	@echo "Building for $(HOST_DETECT)"
	@mkdir -p build
	@cd $(QNX_PROJECT_ROOT) && sh autogen.sh
	@cd build && $(QNX_PROJECT_ROOT)/configure --host=$(HOST_DETECT) --disable-pulseaudio
	@cd build && make $(MAKE_ARGS)

#Unfortunately 2.0.5's 
install: SDL_all
	@echo Installing...
	@cd build && make $(MAKE_ARGS) install
	@echo Done!

test check: install
	@mkdir -p build_test 
	@cd build_test && $(CONFIGURE_PREOPTS) $(QNX_PROJECT_ROOT)/test/configure --host=$(HOST_DETECT)
	@cd build_test &&  make $(MAKE_ARGS)

clean:
	rm -rf build
	rm -rf build_test
endif