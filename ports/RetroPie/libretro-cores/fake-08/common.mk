ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

### Root of project
QNX_PROJECT_ROOT?=$(PRODUCT_ROOT)/../../../../fake-08

ALL_DEPENDENCIES = fake08_all
.PHONY: fake08_all install

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

fake08_all:
	@mkdir -p build
	@cd $(QNX_PROJECT_ROOT)/platform/libretro && make clean
	@cd $(QNX_PROJECT_ROOT) && make -Cplatform/libretro HOST=$(PLATFORM)-nto CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT)" CXX="$(QNX_HOST)/usr/bin/q++ -V$(V_OPT)_cxx" platform=qnx 
	@cd build && cp $(QNX_PROJECT_ROOT)/platform/libretro/*libretro*.so .

install:
	@echo "Installing..."
	mkdir -p $(PRODUCT_ROOT)/../staging/$(CPUDIR)/data/cores/
	cd build && cp * $(PRODUCT_ROOT)/../staging/$(CPUDIR)/data/cores/

clean:
	rm -rf build