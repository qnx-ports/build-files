include ../common.mk

CMAKE_ARGS += -DCMAKE_SYSTEM_PROCESSOR=aarch64
FLAGS      += $(VFLAG_le) $(CCVFLAG_le)
FLAGS      += -march=armv8-a+simd
FLAGS      += -Wno-ignored-attributes
LDFLAGS    += $(VFLAG_le) $(LDVFLAG_le)
