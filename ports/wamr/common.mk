ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

NAME=wamr

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

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

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

ALL_DEPENDENCIES = $(NAME)_all
.PHONY: $(NAME)_all install check clean

CFLAGS += $(FLAGS)

#Define _QNX_SOURCE for LLVM libc++ on QNX 7
#-O2 rather than -O3: WAMR ships computed-goto interpreter dispatch tables whose address
#arithmetic is not aggressive-optimisation friendly, and upstream builds Release with -O2.
CFLAGS += -D_QNX_SOURCE -O2 -fPIC
LDFLAGS += -Wl,--build-id=md5

include $(MKFILES_ROOT)/qtargets.mk

# --- WAMR specific -----------------------------------------------------------

# WAMR's per-target CMake project lives in a subdirectory, not at the repository root.
# Requires the QNX platform support (core/shared/platform/qnx and
# product-mini/platforms/qnx) to be present in the checked out tree.
WAMR_SRC ?= $(QNX_PROJECT_ROOT)/product-mini/platforms/qnx

# Build options. Names are WAMR's own (see doc/build_wamr.md upstream).
# Defaults follow the upstream QNX port: interpreter + fast interpreter + AOT loader,
# WASI, pthread library and call-stack dumping. Override any of them on the make line.
WAMR_BUILD_INTERP        ?= 1
WAMR_BUILD_FAST_INTERP   ?= 1
WAMR_BUILD_AOT           ?= 1
WAMR_BUILD_JIT           ?= 0
WAMR_BUILD_LIBC_BUILTIN  ?= 1
WAMR_BUILD_LIBC_WASI     ?= 1
WAMR_BUILD_LIB_PTHREAD   ?= 1
WAMR_BUILD_DUMP_CALL_STACK ?= 1

#Search paths for all of CMake's find_* functions --
#headers, libraries, etc.
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)

#Path to CMake modules; These are CMake files installed by other packages
#for downstreams to discover them automatically.
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake

#Headers from INSTALL_ROOT need to be made available by default
CFLAGS += -I$(INSTALL_ROOT)/$(PREFIX)/include -I$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/include

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_SYSTEM_PROCESSOR_ENDIAN=$(CPUVARDIR) \
             -DCMAKE_SYSTEM_PROCESSOR=$(CPU) \
             -DEXTRA_CMAKE_ASM_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
             -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
             -DCMAKE_CXX_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_C_COMPILER_TARGET=gcc_nto$(CPUVARDIR) \
             -DCMAKE_INSTALL_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCMAKE_INSTALL_INCLUDEDIR="$(INSTALL_ROOT)/$(PREFIX)/include" \
             -DCMAKE_MODULE_PATH="$(CMAKE_MODULE_PATH)" \
             -DCMAKE_FIND_ROOT_PATH="$(CMAKE_FIND_ROOT_PATH)" \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DWAMR_BUILD_TARGET=$(WAMR_BUILD_TARGET_$(CPUVARDIR)) \
             -DWAMR_BUILD_INTERP=$(WAMR_BUILD_INTERP) \
             -DWAMR_BUILD_FAST_INTERP=$(WAMR_BUILD_FAST_INTERP) \
             -DWAMR_BUILD_AOT=$(WAMR_BUILD_AOT) \
             -DWAMR_BUILD_JIT=$(WAMR_BUILD_JIT) \
             -DWAMR_BUILD_LIBC_BUILTIN=$(WAMR_BUILD_LIBC_BUILTIN) \
             -DWAMR_BUILD_LIBC_WASI=$(WAMR_BUILD_LIBC_WASI) \
             -DWAMR_BUILD_LIB_PTHREAD=$(WAMR_BUILD_LIB_PTHREAD) \
             -DWAMR_BUILD_DUMP_CALL_STACK=$(WAMR_BUILD_DUMP_CALL_STACK)

# WAMR names its targets X86_64 / AARCH64, while the ports tree names them x86_64 / aarch64le.
# The mapping must key on CPUVARDIR, not CPU: on this tree CPU is "aarch64" while CPUVARDIR is
# "aarch64le" — the same split as the binutils (ntoaarch64-ar) and the qcc variant
# (-Vgcc_ntoaarch64le). Keying on CPU silently produced an empty WAMR_BUILD_TARGET.
WAMR_BUILD_TARGET_x86_64    = X86_64
WAMR_BUILD_TARGET_aarch64le = AARCH64
WAMR_BUILD_TARGET_aarch64   = AARCH64

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

$(NAME)_all:
	@test -d "$(WAMR_SRC)" || { \
	  echo "ERROR: $(WAMR_SRC) not found."; \
	  echo "QNX_PROJECT_ROOT must point at a WAMR tree that contains the QNX platform"; \
	  echo "support (core/shared/platform/qnx and product-mini/platforms/qnx)."; \
	  exit 1; }
	@mkdir -p build
	@cd build && cmake $(CMAKE_ARGS) $(WAMR_SRC)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: $(NAME)_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
