ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)
##################################################

### Project Options
NAME= libretro-test
QNX_PROJECT_ROOT ?= $(PROJECT_ROOT)/../../../../../libretro-samples
PREFIX ?= /usr/local

### Setting up default target
ALL_DEPENDENCIES = libretrotest_all
.PHONY: libretrotest_all install clean


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

libretrotest_all:
	@echo "Building for $(PLATFORM)"
	@mkdir -p build/test_1
	@mkdir -p build/test_2
	@mkdir -p build/test_3
#	@mkdir -p build/test_4
#	@mkdir -p build/test_5
#	@mkdir -p build/test_6
	@mkdir -p build/test_7
	@cp -r $(QNX_PROJECT_ROOT)/tests/test/* build/test_1/
	@cp -r $(QNX_PROJECT_ROOT)/tests/test_advanced/* build/test_2/
	@cp -r $(QNX_PROJECT_ROOT)/input/button_test/* build/test_3
#	@cp -r $(QNX_PROJECT_ROOT)/video/vulkan/vk_rendering/* build/test_4
#	@cp -r $(QNX_PROJECT_ROOT)/video/vulkan/vk_async_compute/* build/test_5
#	@cp -r $(QNX_PROJECT_ROOT)/tests/cruzes/* build/test_6
	@cp -r $(QNX_PROJECT_ROOT)/midi/midi_test/* build/test_7
	@cd build/test_1 && make $(MAKE_ARGS)
	@cd build/test_2 && make $(MAKE_ARGS)
	@cd build/test_3 && make $(MAKE_ARGS)
#	@cd build/test_4 && make $(MAKE_ARGS)
#	@cd build/test_5 && make $(MAKE_ARGS)
#	@cd build/test_6 && make $(MAKE_ARGS)
	@cd build/test_7 && make $(MAKE_ARGS)

#Should go to staging/cpudir/cores
install: libretrotest_all
	@mkdir -p ../../../staging/$(CPUDIR)/retroarch/data/cores/tests
	@cp build/test_1/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/test_libretro.so
	@cp build/test_2/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/advanced_tests_libretro.so
	@cp build/test_3/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/button_test_libretro.so
#	@cp build/test_4/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/
#	@cp build/test_5/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/
#	@cp build/test_6/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/
	@cp build/test_7/*libretro*.so ../../../staging/$(CPUDIR)/retroarch/data/cores/tests/midi_test_libretro.so

clean:
	rm -rf build