# Skip ARM v7 build for QNX 8.0
ifneq (,$(or $(findstring qnx800,$(QNX_TARGET)),$(findstring qnx/800,$(QNX_TARGET))))
install check:
	@echo "ARM v7 build is not supported for QNX 8.0. skipping..."

clean iclean spotless:
	@echo "ARM v7 build is not supported for QNX 8.0. skipping..."
else
include ../../common.mk

CMAKE_ARGS += -DCMAKE_SYSTEM_PROCESSOR=armv7le
EXT = v7
endif