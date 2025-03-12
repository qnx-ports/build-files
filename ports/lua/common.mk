ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
##################################################

#### Project Options
NAME = lua
QNX_PROJECT_ROOT ?= $(PROJECT_ROOT)/../../../lua
PREFIX ?= /usr/local
CMAKE_BUILD_TYPE ?= Release

#### Set up default target (QNX-specific) 
#Overriding `all` bypasses built-in qnx stuff.
ALL_DEPENDENCIES = lua_all
.PHONY: lua_all clean

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
MAKE_PREOPTS= 	   CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT) -Wno-deprecated-declarations " \
				   AR="$(QNX_HOST)/usr/bin/nto$(CPU)-ar cq "\
				   RANLIB=$(QNX_HOST)/usr/bin/nto$(CPU)-gcc-ranlib \
				   CFLAGS="-D_QNX_SOURCE -DLUA_USE_QNX -std=c99 -V$(V_OPT) $(FLAGS)" \
				   LD="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT)"


				#    LD=$(HOST_DETECT)-ld \
				#    CFLAGS="-D_QNX_SOURCE -std=c99 -V$(V_OPT) $(FLAGS)" \
				#    CXXFLAGS="-D_QNX_SOURCE -std=c++17 -V$(V_OPT)_cxx -Wno-deprecated-definitions $(FLAGS)"\
				#    LDFLAGS="-D_QNX_SOURCE -std=c17 -V$(V_OPT) $(FLAGS)" \
				#    CPPFLAGS="-D_QNX_SOURCE $(CPPFLAGS)" \

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1) VERBOSE=1

##################################################
#### Make Targets || 2.0.5 ####
ifndef NO_TARGET_OVERRIDE
lua_all:
	@echo "Building for $(HOST_DETECT)"
	@mkdir -p build
	@cp -r $(QNX_PROJECT_ROOT)/* build/
	@cp ../LuaMakefile.qnx build/
	@cd build && $(MAKE_PREOPTS) make $(MAKE_ARGS) -fLuaMakefile.qnx
	
install: lua_all
	@cd build && $(MAKE_PREOPTS) make $(MAKE_ARGS) -fLuaMakefile.qnx

lua_tests: lua_all install
	@cd build/testes/libs && $(MAKE_PREOPTS) make $(MAKE_ARGS) -fmakefile.qnx
	@mkdir -p test_staging/lib
	@mkdir -p test_staging/test
	@cp build/*.a test_staging/lib/
	@cp $(QNX_TARGET)/$(CPUDIR)/$(PREFIX)/lib/*muslflt* test_staging/lib/
	@cp -r build/testes/* test_staging/test/
	@cp build/lua test_staging/

install_rpie: lua_tests
	@mkdir -p ../../RetroPie/staging/$(CPUDIR)/lib
	@mkdir -p ../../RetroPie/staging/$(CPUDIR)/lua/test
	-cp test_staging/lib/* ../../RetroPie/staging/$(CPUDIR)/lib/
	-cp build/lua ../../RetroPie/staging/$(CPUDIR)/lua/
	-cp -r build/testes/* ../../RetroPie/staging/$(CPUDIR)/lua/test/

clean:
	-rm -rf build
	-rm -rf test_staging
endif