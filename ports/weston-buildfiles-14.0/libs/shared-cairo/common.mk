ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib

EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../nto
EXTRA_INCVPATH += $(addsuffix /cairo,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))

EXTRA_SRCVPATH += $(DIST_ROOT)/shared
# Stops build system from setting INCVPATH=$(EXTRA_SRCVPATH)
# Will still append EXTRA_INCVPATH as expected. There is a
# signal.h file in weston source conflicting with OS signal.h
INCVPATH = $(empty)

# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS = \
	config-parser.c \
	option-parser.c \
	file-util.c \
	os-compatibility.c \
	image-loader.c \
	cairo-util.c \
	frame.c \
	process-util.c

RESOURCES = \
	$(DIST_ROOT)/data/icon_window.png \
	$(DIST_ROOT)/data/sign_close.png \
	$(DIST_ROOT)/data/sign_maximize.png \
	$(DIST_ROOT)/data/sign_minimize.png

include $(MKFILES_ROOT)/qtargets.mk

POST_INSTALL += $(CP_HOST) $(RESOURCES) $(INSTALL_ROOT_$(OS))/usr/share/weston/;
