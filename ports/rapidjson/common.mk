#### QNX Setup
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
##################################################

#### Project Options
NAME = rapidjson
QNX_PROJECT_ROOT ?= $(PROJECT_ROOT)/../../../rapidjson
PREFIX ?= /usr/local
CMAKE_BUILD_TYPE ?= Release

#### Set up default target (QNX-specific) 
#Overriding `all` bypasses built-in qnx stuff.
ALL_DEPENDENCIES = rapidjson_all
.PHONY: rapidjson_all install check clean

#### LD Flags and global C/C++ Flags
FLAGS   += -g -D_QNX_SOURCE
LDFLAGS += -Wl

##################################################
include $(MKFILES_ROOT)/qtargets.mk
##################################################

#### cmake Package Configuration
INSTALL_ROOT?=$(QNX_TARGET)
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
			 -DCMAKE_INSTALL_PREFIX:STRING=$(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX) \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \

ifdef BUILD_TESTS
GTEST_SRC?=$(PROJECT_ROOT)/../../../googletest

CMAKE_ARGS+= -DGTEST_SOURCE_DIR=$(GTEST_SRC) \
			 -DRAPIDJSON_BUILD_CXX17=ON \
			 -DRAPIDJSON_BUILD_CXX11=OFF
endif

#### Flags for g++/gcc C/CPP 
CFLAGS +=   -I$(INSTALL_ROOT)/$(PREFIX)/include \
			-I$(QNX_TARGET)/$(PREFIX)/include \
			-D_QNX_SOURCE

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1) VERBOSE=1

#### Make Targets ####
ifndef NO_TARGET_OVERRIDE
rapidjson_all:
	@mkdir -p build
	@echo $(CPUDIR)
	@cd build && cmake $(CMAKE_ARGS) $(QNX_PROJECT_ROOT)
	@cd build && make

ifdef BUILD_TESTS
install check: rapidjson_all
	@echo Installing...
	@cd build && cmake --install .
	@echo "Copying tests..."
	@cd build/bin && cp -r $(QNX_PROJECT_ROOT)/bin/* .
	@mkdir -p $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin/rapidjson_tests/
	@echo Tests in $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin/rapidjson_tests/
	@cd build/bin && cp -r * $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/bin/rapidjson_tests/
	@echo Done!
else
install check: rapidjson_all
	@echo Installing...
	@cd build && cmake --install .
	@echo Done!
endif

clean:
	rm -rf build
endif