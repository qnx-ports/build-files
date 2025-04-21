ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../../

PREFIX ?= /usr/local

CCFLAGS += -fvisibility=hidden
LDFLAGS += -Wl,--exclude-libs,ALL -Wl,--unresolved-symbols=report-all
USEFILE :=

EXTRA_SRCVPATH = $(QNX_PROJECT_ROOT)/epoll
