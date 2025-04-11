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

#### Set up default target (QNX-specific) 
#Overriding `all` bypasses built-in qnx stuff.
ALL_DEPENDENCIES = SDL_all
.PHONY: SDL_all install check clean SDL_test

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
ifneq (,$(findstring x86_64,$(CPUDIR)))
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
             -DSDL_THREADS_ENABLED_BY_DEFAULT=ON


#### Flags for g++/gcc C/CPP 
CFLAGS +=   -I$(INSTALL_ROOT)/$(PREFIX)/include \
			-I$(QNX_TARGET)/$(PREFIX)/include \
			$(FLAGS)

#### configure options
CONFIGURE_OPTS=	--prefix=$(pwd)/dist \
				--exec-prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) \
				--libdir=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib \
				--bindir=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin \
				--sysconfdir=$(QNX_TARGET)/etc \
				--oldincludedir=$(QNX_TARGET)/$(CPUVARDIR)/old/include 

CONFIGURE_PREOPTS= CC=$(QNX_HOST)/usr/bin/qcc \
				   CXX=$(QNX_HOST)/usr/bin/q++ \
				   LD=$(HOST_DETECT)-ld \
				   CFLAGS="-D_QNX_SOURCE -std=c17 -V$(V_OPT) $(FLAGS)"\
				   CXXFLAGS="-D_QNX_SOURCE -std=c++17 -V$(V_OPT)_cxx -Wno-deprecated-definitions $(FLAGS)"\
				   LDFLAGS=$(LDFLAGS) \
				   CPPFLAGS="-D_QNX_SOURCE $(CPPFLAGS)"\

TEST_CONFIGURE_PREOPTS= CC=$(QNX_HOST)/usr/bin/qcc \
				  	 	CXX=$(QNX_HOST)/usr/bin/q++ \
				   		LD=$(QNX_HOST)/usr/bin/qcc \
						CFLAGS="-I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include/SDL2 -D_QNX_SOURCE -std=c17 -V$(V_OPT) $(FLAGS) -I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include"\
						CXXFLAGS="-D_QNX_SOURCE -std=c++17 -V$(V_OPT)_cxx -Wno-deprecated-definitions $(FLAGS)"\
						CPPFLAGS="-D_QNX_SOURCE $(CPPFLAGS)"\
						LDFLAGS="-L$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib" \
						PKG_CONFIG_LIBDIR="$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig"\
						SDL_LIBS="-L$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib -lSDL2"\
						SDL_CFLAGS="-I$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include/SDL2  -D_REENTRANT"


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
	@cd build && $(QNX_PROJECT_ROOT)/configure --host=$(HOST_DETECT) --disable-pulseaudio --enable-wayland-shared=no --enable-video-wayland=no --enable-joystick=yes --enable-audio=no --prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)
	@cd build && make $(MAKE_ARGS)
	@cd build && cp $(QNX_PROJECT_ROOT)/include/* include/

#Unfortunately 2.0.5's install script is not viable for QNX.
#	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/
#	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/
#	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/SDL/
#	@cp build/build/libSDL*.a $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/
#	@cp build/build/.libs/libSDL* $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/
# 	@cp build/include/SDL_config.h  $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/SDL/
#	@cp build/*.pc $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/
#	@cp build/*.cmake $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/
install: SDL_all
	@echo Installing...
	@cd build && $(QNX_PROJECT_ROOT)/configure --host=$(HOST_DETECT) --disable-pulseaudio --enable-wayland-shared=no --enable-video-wayland=no --enable-joystick=yes --enable-audio=no --prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)
	@cd build && make $(MAKE_ARGS) install
	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/
	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/
	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include/SDL/
	@cp build/build/libSDL*.a $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/
	@cp build/build/.libs/libSDL* $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/
	@cp build/include/*.h  $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/include/SDL/
	@sed -i s+prefix=.*+prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)+ build/sdl2.pc
	@cp build/*.pc $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/pkgconfig/
	@cp build/*.cmake $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake/

# Shortcut for RetroPie's build/install all script
install_rpie: install
	@mkdir -p $(PRODUCT_ROOT)/staging/$(CPUDIR)/lib/
	@cp build/build/.libs/*.so* $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/
	@cp build/build/.libs/*.a* $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/
	@cp build/build/.libs/*.la $(PRODUCT_ROOT)/RetroPie/staging/$(CPUDIR)/lib/


SDL_test check: install
	@mkdir -p build/test 
	@cd build/test && $(TEST_CONFIGURE_PREOPTS) $(QNX_PROJECT_ROOT)/test/configure --host=$(HOST_DETECT) --disable-pulseaudio --enable-wayland-shared=no --enable-video-wayland=no --enable-joystick=yes --enable-audio=no --prefix=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)
	@make -i $(TEST_CONFIGURE_PREOPTS) $(MAKE_ARGS) -C build/test
	@mkdir -p staging
	@mkdir -p staging/lib
	-cp build/test/test* staging/
	-cp build/test/*.bmp staging/
	-cp build/test/*.txt staging/
	-cp build/test/checkkeys staging/
	-cp build/test/loopwave* staging/
	-cp build/test/torturethread staging/
	-cp build/test/*.wav staging/
	-cp ../run_tests.sh staging/
	-cp build/build/libSDL*.a staging/lib
	-cp build/build/.libs/libSDL* staging/lib
	@echo "Test Setup Staged in $(pwd)/staging !"
	@echo "Copy to target with scp staging <user>@<ip-addr>:/testing/dir/path"

clean:
	-rm -rf build
	-rm -rf build/test
	-rm -rf staging
endif