ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=gl-renderer

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/lib/libweston

EXTRA_INCVPATH += $(DIST_ROOT)/libweston
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol
EXTRA_INCVPATH += $(addsuffix /pixman-1,$(USE_ROOT_INCLUDE))
EXTRA_INCVPATH += $(addsuffix /libdrm,$(USE_ROOT_INCLUDE))
include ../../../../../extra_incvpath.mk

EXTRA_SRCVPATH += $(DIST_ROOT)/libweston/renderer-gl
EXTRA_SRCVPATH += $(DIST_ROOT)/libweston
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)
EXTRA_SRCVPATH += $(PROJECT_ROOT)/../../$(OS)/protocol

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/a.shared\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/weston/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^dll\(.*\)$$/so\1/')

# Hide symbols from static libraries.
LDFLAGS += -Wl,--exclude-libs,ALL
# Report unresolved symbols at build time
LDFLAGS += -Wl,--unresolved-symbols=report-all

SRCS += \
	gl-renderer.c \
	egl-glue.c \
	vertex-clipping.c \
	gl-shaders.c \
	gl-shader-config-color-transformation.c \
	$(if $(filter so dll,$(VARIANT_LIST)),epoll-create-stub.c) \
	$(if $(filter so dll,$(VARIANT_LIST)),socketpair-stub.c) \
	linux-dmabuf-unstable-v1-protocol.c
LIBS += weston sharedS wayland-server pixman-1 EGL GLESv2 memstream m

define PINFO
PINFO DESCRIPTION = Weston GL Render Library
endef

include $(MKFILES_ROOT)/qtargets.mk
