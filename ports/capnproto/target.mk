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
PREFIX ?= /usr/local

# Use muslflt automatically if it exists
ifneq ($(USE_MUSLFLT), false)
ifneq ($(wildcard $(INSTALL_ROOT_$(OS))/$(CPUVARDIR)/usr/local/lib/libmuslflt.a),)
$(info libmuslflt.a found in INSTALL_ROOT, linking automatically)
USE_MUSLFLT := true
endif
endif

ifeq ($(USE_MUSLFLT), true)
EXTRA_LDFLAGS :=  -Wl,--whole-archive -lmuslflt -Wl,--no-whole-archive
endif

CMAKE_ARGS += -DEXTRA_CMAKE_LINKER_FLAGS="$(EXTRA_LDFLAGS)" \
              -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
              -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
              -DCMAKE_CROSSCOMPILING=ON \
              -DCMAKE_INSTALL_PREFIX=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
              -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include \
              -DCMAKE_PREFIX_PATH=$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX) \
              -DQNX_NTO_TOOLCHAIN_PREFIX="$(CPU)" \
              -DCPUVARDIR=$(CPUVARDIR) \
              -DEXTERNAL_CAPNP:BOOL=ON \

export CAPNP=$(QNX_HOST)/usr/bin/capnp
export CAPNP_CXX=$(QNX_HOST)/usr/bin/capnpc-c++
