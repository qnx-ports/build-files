ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
##################################################

### Project Options
NAME= mrboom-libretro
QNX_PROJECT_ROOT ?= $(PROJECT_ROOT)/../../../../../mrboom-libretro
PREFIX ?= /usr/local

### Setting up default target
ALL_DEPENDENCIES = mrboom_all
.PHONY: mrboom_all install clean


##################################################
include $(MKFILES_ROOT)/qtargets.mk
##################################################

### Determining Host
## QNX 8.0.x
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


MAKE_ARGS = 	HOST=$(PLATFORM)-nto \
				CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT) -D_QNX_SOURCE" \
			   	CXX="$(QNX_HOST)/usr/bin/q++ -V$(V_OPT)_cxx -D_QNX_SOURCE" \
				platform=qnx \

##################################################

mrboom_all:
	@mkdir -p build
	@cd $(QNX_PROJECT_ROOT) && make clean
	@cd $(QNX_PROJECT_ROOT) && make HOST=$(PLATFORM)-nto CC="$(QNX_HOST)/usr/bin/qcc -V$(V_OPT)" CXX="$(QNX_HOST)/usr/bin/q++ -V$(V_OPT)_cxx" platform=qnx -fMakefile
	@cp $(QNX_PROJECT_ROOT)/*.so build/

#Should go to staging/cpudir/data/cores
install: mrboom_all
	@echo "Installing..."
	mkdir -p $(PRODUCT_ROOT)/../staging/$(CPUDIR)/data/cores/
	cd build && cp *libretro*.so $(PRODUCT_ROOT)/../staging/$(CPUDIR)/data/cores/

clean:
	rm -rf build