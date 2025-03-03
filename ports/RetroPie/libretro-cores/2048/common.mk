ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

### Root of project
QNX_PROJECT_ROOT?=$(PRODUCT_ROOT)/../../../../libretro-2048

ALL_DEPENDENCIES = 2048_all
.PHONY: 2048_all install

###################################
include $(MKFILES_ROOT)/qtargets.mk
###################################

### CPU Architecture Detection
ifeq ($(CPUDIR), aarch64le)
PLATFORM=aarch64-unknown
V_OPT=gcc_ntoaarch64le
else ifeq ($(CPUDIR), x86_64)
PLATFORM=x86_64-pc
V_OPT=gcc_ntox86_64
else
$(error Not a supported CPU.)
endif

#NOTE: x86_64 may not actually work at the moment...

2048_all:
	@mkdir -p build
	@cd $(QNX_PROJECT_ROOT) && make -fMakefile.libretro clean
	@cd $(QNX_PROJECT_ROOT) && make HOST=$(PLATFORM)-nto CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT) -D_QNX_SOURCE" CXX="$(QNX_HOST)/usr/bin/q++ -V$(V_OPT)_cxx -std=c++11 -D_QNX_SOURCE" platform=qnx -fMakefile.libretro
	@cd build && cp $(QNX_PROJECT_ROOT)/*libretro*.so .

install:
	@echo "Installing..."
	mkdir -p $(PRODUCT_ROOT)/../staging/$(CPUDIR)/retroarch/data/cores/
	cd build && cp * $(PRODUCT_ROOT)/../staging/$(CPUDIR)/retroarch/data/cores/