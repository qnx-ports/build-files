ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

INCLUDE_DIR ?= $(INSTALL_ROOT_nto)/usr/include/libdrm
DIST_ROOT ?= $(PROJECT_ROOT)

# Source directories
SRC_DIR1 = $(DIST_ROOT)/include/drm
SRC_DIR2 = $(DIST_ROOT)

# Header files
HEADERS1 = $(wildcard $(SRC_DIR1)/*.h)
HEADERS2 = $(wildcard $(SRC_DIR2)/*.h)

# Default target
all:
	@echo "Run 'make install' to install libdrm headers."

# Install headers
install:
	$(CP_HOST) $(HEADERS1) $(INCLUDE_DIR)/
	$(CP_HOST) $(HEADERS2) $(INCLUDE_DIR)/

clean:
	$(RM_HOST) $(TARGET)$(INCLUDE_DIR)/*

